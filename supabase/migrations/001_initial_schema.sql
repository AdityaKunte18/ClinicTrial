-- ============================================================================
-- ClinicalPilot: Initial Database Schema
-- Migration: 001_initial_schema.sql
-- Description: Creates all 13 tables, indexes, helper functions, and RLS policies
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABLE 1: hospitals
-- Core hospital registry. All data is scoped to a hospital.
-- ============================================================================
CREATE TABLE public.hospitals (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  city        TEXT        NOT NULL,
  type        TEXT        NOT NULL CHECK (type IN ('government', 'municipal', 'teaching', 'private')),
  mjpjay_empanelled BOOLEAN DEFAULT false,
  pmjay_empanelled  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.hospitals IS 'Registry of hospitals using ClinicalPilot';

-- ============================================================================
-- TABLE 2: users
-- Application users linked to Supabase auth. Each user belongs to one hospital.
-- ============================================================================
CREATE TABLE public.users (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id     UUID        UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  email       TEXT        UNIQUE NOT NULL,
  phone       TEXT,
  role        TEXT        NOT NULL CHECK (role IN ('admin', 'consultant', 'jr3', 'jr2', 'jr1')),
  hospital_id UUID        REFERENCES public.hospitals(id),
  unit        TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.users IS 'Application user profiles linked to Supabase Auth';

-- ============================================================================
-- HELPER FUNCTION: get_user_hospital_id()
-- Returns the hospital_id for the currently authenticated Supabase user.
-- Used throughout RLS policies to scope data access per hospital.
-- NOTE: Defined after public.users table is created.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_user_hospital_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT hospital_id
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;
$$;

-- Helper: returns the role of the currently authenticated user.
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role
  FROM public.users
  WHERE auth_id = auth.uid()
  LIMIT 1;
$$;

-- ============================================================================
-- TABLE 3: patients
-- Patient demographics and scheme eligibility.
-- ============================================================================
CREATE TABLE public.patients (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  uhid                VARCHAR     UNIQUE NOT NULL,
  name                TEXT        NOT NULL,
  age                 INTEGER     NOT NULL,
  sex                 TEXT        NOT NULL CHECK (sex IN ('M', 'F', 'Other')),
  phone               TEXT,
  aadhaar_encrypted   TEXT,
  ration_card_type    TEXT        CHECK (ration_card_type IN ('yellow', 'orange', 'antyodaya', 'annapurna', 'white', NULL)),
  pmjay_eligible      BOOLEAN     DEFAULT false,
  mjpjay_eligible     BOOLEAN     DEFAULT false,
  ayushman_card_number TEXT,
  created_at          TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.patients IS 'Patient demographics, identifiers, and government scheme eligibility';

-- ============================================================================
-- TABLE 4: syndrome_protocols
-- Master clinical syndrome definitions with versioned protocol templates.
-- NOTE: Created before admissions/admission_syndromes because they reference it.
-- ============================================================================
CREATE TABLE public.syndrome_protocols (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code          VARCHAR     UNIQUE NOT NULL,  -- e.g. 'SYN-01-FEVER'
  name          TEXT        NOT NULL,
  category      TEXT,
  version       INTEGER     DEFAULT 1,
  is_active     BOOLEAN     DEFAULT true,
  base_template JSONB       NOT NULL,
  created_by    UUID        REFERENCES public.users(id),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.syndrome_protocols IS 'Master syndrome definitions with versioned clinical protocol templates (JSONB)';

-- ============================================================================
-- TABLE 5: admissions
-- Active and historical patient admissions. Central entity for clinical workflow.
-- ============================================================================
CREATE TABLE public.admissions (
  id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id              UUID        NOT NULL REFERENCES public.patients(id),
  hospital_id             UUID        NOT NULL REFERENCES public.hospitals(id),
  bed_number              TEXT,
  admission_date          TIMESTAMPTZ NOT NULL DEFAULT now(),
  expected_discharge      TIMESTAMPTZ,
  actual_discharge_date   TIMESTAMPTZ,
  admitting_doctor_id     UUID        NOT NULL REFERENCES public.users(id),
  status                  TEXT        NOT NULL DEFAULT 'active'
                                      CHECK (status IN ('active', 'discharged', 'transferred', 'lama', 'expired')),
  current_day             INTEGER     DEFAULT 1,
  discharge_blocked       BOOLEAN     DEFAULT false,
  discharge_block_reasons JSONB       DEFAULT '[]'::jsonb,
  created_at              TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.admissions IS 'Patient admissions -- the central entity tying patients, hospitals, doctors, and clinical workflows';

-- ============================================================================
-- TABLE 6: admission_syndromes
-- Many-to-many link between admissions and syndrome protocols.
-- ============================================================================
CREATE TABLE public.admission_syndromes (
  id               UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  admission_id     UUID    NOT NULL REFERENCES public.admissions(id) ON DELETE CASCADE,
  syndrome_id      UUID    NOT NULL REFERENCES public.syndrome_protocols(id),
  is_primary       BOOLEAN DEFAULT false,
  detected_by      TEXT    DEFAULT 'manual' CHECK (detected_by IN ('manual', 'ai_suggested')),
  confidence_score FLOAT
);

COMMENT ON TABLE public.admission_syndromes IS 'Links admissions to one or more syndrome protocols (many-to-many)';

-- ============================================================================
-- TABLE 7: doctor_template_overrides
-- Per-doctor customizations of syndrome protocol templates.
-- ============================================================================
CREATE TABLE public.doctor_template_overrides (
  id                UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id         UUID    NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  syndrome_id       UUID    NOT NULL REFERENCES public.syndrome_protocols(id),
  override_template JSONB   NOT NULL,
  version           INTEGER DEFAULT 1,
  UNIQUE (doctor_id, syndrome_id)
);

COMMENT ON TABLE public.doctor_template_overrides IS 'Doctor-specific overrides to base syndrome protocol templates';

-- ============================================================================
-- TABLE 8: workup_items
-- Individual clinical tasks (labs, imaging, treatments, etc.) for an admission.
-- ============================================================================
CREATE TABLE public.workup_items (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  admission_id   UUID        NOT NULL REFERENCES public.admissions(id) ON DELETE CASCADE,
  syndrome_id    UUID        REFERENCES public.syndrome_protocols(id),
  domain         TEXT        NOT NULL CHECK (domain IN (
                               'history', 'examination', 'blood', 'radiology',
                               'treatment', 'referral', 'scheme_prereq', 'discharge')),
  item_text      TEXT        NOT NULL,
  is_required    BOOLEAN     DEFAULT false,
  is_hard_block  BOOLEAN     DEFAULT false,
  target_day     INTEGER,
  status         TEXT        DEFAULT 'pending' CHECK (status IN (
                               'pending', 'ordered', 'sent', 'resulted',
                               'reviewed', 'done', 'not_applicable', 'deferred_opd')),
  result_value   TEXT,
  completed_by   UUID        REFERENCES public.users(id),
  completed_at   TIMESTAMPTZ,
  notes          TEXT,
  ai_suggested   BOOLEAN     DEFAULT false,
  reminder_level TEXT        DEFAULT 'none' CHECK (reminder_level IN (
                               'none', 'nudge', 'firm', 'escalation', 'block')),
  category       VARCHAR,
  sort_order     INTEGER     DEFAULT 0,
  created_at     TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.workup_items IS 'Granular clinical workup checklist items (labs, exams, treatments) tied to an admission';

-- ============================================================================
-- TABLE 9: orders
-- Clinical orders generated from workup items, templates, or AI suggestions.
-- ============================================================================
CREATE TABLE public.orders (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  workup_item_id UUID        REFERENCES public.workup_items(id) ON DELETE SET NULL,
  admission_id   UUID        NOT NULL REFERENCES public.admissions(id) ON DELETE CASCADE,
  order_type     TEXT        NOT NULL CHECK (order_type IN (
                               'investigation', 'treatment', 'radiology',
                               'referral', 'diet', 'nursing')),
  order_text     TEXT        NOT NULL,
  details        JSONB,
  status         TEXT        DEFAULT 'draft' CHECK (status IN (
                               'draft', 'confirmed', 'sent', 'executed', 'cancelled')),
  ordered_by     UUID        REFERENCES public.users(id),
  generated_by   TEXT        DEFAULT 'template' CHECK (generated_by IN ('template', 'ai', 'manual')),
  created_at     TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.orders IS 'Clinical orders (labs, meds, radiology, referrals) linked to workup items and admissions';

-- ============================================================================
-- TABLE 10: scheme_packages
-- Government health scheme package definitions (MJPJAY / PMJAY).
-- ============================================================================
CREATE TABLE public.scheme_packages (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  scheme              TEXT        NOT NULL CHECK (scheme IN ('mjpjay', 'pmjay')),
  specialty_code      TEXT        NOT NULL,
  package_code        TEXT        NOT NULL,
  package_name        TEXT        NOT NULL,
  package_amount      INTEGER     DEFAULT 0,
  government_reserved BOOLEAN     DEFAULT false,
  prerequisites       JSONB,
  linked_syndromes    UUID[],
  is_active           BOOLEAN     DEFAULT true,
  version             INTEGER     DEFAULT 1,
  last_verified       DATE
);

COMMENT ON TABLE public.scheme_packages IS 'MJPJAY and PMJAY government health scheme package definitions and prerequisites';

-- ============================================================================
-- TABLE 11: reminders
-- Escalating reminder/nudge system for incomplete workup items.
-- ============================================================================
CREATE TABLE public.reminders (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  workup_item_id  UUID        REFERENCES public.workup_items(id) ON DELETE CASCADE,
  admission_id    UUID        NOT NULL REFERENCES public.admissions(id) ON DELETE CASCADE,
  target_user_id  UUID        NOT NULL REFERENCES public.users(id),
  level           TEXT        NOT NULL CHECK (level IN ('nudge', 'firm', 'escalation', 'block')),
  message         TEXT        NOT NULL,
  ai_context      TEXT,
  sent_at         TIMESTAMPTZ DEFAULT now(),
  acknowledged    BOOLEAN     DEFAULT false,
  acknowledged_at TIMESTAMPTZ
);

COMMENT ON TABLE public.reminders IS 'Escalating reminders (nudge -> firm -> escalation -> block) for incomplete clinical tasks';

-- ============================================================================
-- TABLE 12: guideline_updates
-- Tracks external clinical guideline changes detected by AI scanning.
-- ============================================================================
CREATE TABLE public.guideline_updates (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_date             DATE        NOT NULL,
  source                TEXT        NOT NULL,
  source_url            TEXT,
  affected_syndrome_id  UUID        REFERENCES public.syndrome_protocols(id),
  affected_field        TEXT,
  change_summary        TEXT        NOT NULL,
  current_value         TEXT,
  proposed_value        TEXT,
  status                TEXT        DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'deferred')),
  reviewed_by           UUID        REFERENCES public.users(id),
  reviewed_at           TIMESTAMPTZ,
  reviewer_notes        TEXT
);

COMMENT ON TABLE public.guideline_updates IS 'AI-detected changes in external clinical guidelines requiring admin review';

-- ============================================================================
-- TABLE 13: audit_log
-- Immutable audit trail for all significant data mutations.
-- ============================================================================
CREATE TABLE public.audit_log (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        REFERENCES public.users(id),
  action      TEXT        NOT NULL,
  entity_type TEXT        NOT NULL,
  entity_id   UUID,
  old_value   JSONB,
  new_value   JSONB,
  timestamp   TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.audit_log IS 'Immutable audit trail capturing all significant data changes across the system';

-- ============================================================================
-- INDEXES
-- Performance indexes for the most common query patterns.
-- ============================================================================

-- workup_items: checklist queries by admission, filtering by status/domain/day
CREATE INDEX idx_workup_items_admission_id   ON public.workup_items (admission_id);
CREATE INDEX idx_workup_items_status         ON public.workup_items (status);
CREATE INDEX idx_workup_items_domain         ON public.workup_items (domain);
CREATE INDEX idx_workup_items_day_status     ON public.workup_items (target_day, status);

-- admissions: ward list, patient lookup, hospital-scoped filtering
CREATE INDEX idx_admissions_status           ON public.admissions (status);
CREATE INDEX idx_admissions_patient_id       ON public.admissions (patient_id);
CREATE INDEX idx_admissions_hospital_status  ON public.admissions (hospital_id, status);

-- reminders: per-user unacknowledged reminder queries
CREATE INDEX idx_reminders_user_ack          ON public.reminders (target_user_id, acknowledged);

-- scheme_packages: package lookup by specialty and syndrome linkage
CREATE INDEX idx_scheme_packages_specialty   ON public.scheme_packages (specialty_code);
CREATE INDEX idx_scheme_packages_syndromes   ON public.scheme_packages USING GIN (linked_syndromes);

-- audit_log: entity-based audit trail lookup, per-user audit queries
CREATE INDEX idx_audit_log_entity            ON public.audit_log (entity_type, entity_id);
CREATE INDEX idx_audit_log_user              ON public.audit_log (user_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- All tables have RLS enabled. Policies scope data to the user's hospital.
-- ============================================================================

-- --------------------------------------------------------------------------
-- Enable RLS on every table
-- --------------------------------------------------------------------------
ALTER TABLE public.hospitals              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.syndrome_protocols     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admissions             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admission_syndromes    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctor_template_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workup_items           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheme_packages        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guideline_updates      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log              ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------------------------------------
-- POLICY: hospitals
-- Any authenticated user can view hospitals (needed during signup & general use).
-- Admins can manage their hospital record.
-- --------------------------------------------------------------------------
CREATE POLICY "hospitals_select_authenticated"
  ON public.hospitals FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "hospitals_admin_insert"
  ON public.hospitals FOR INSERT
  WITH CHECK (public.get_user_role() = 'admin');

CREATE POLICY "hospitals_admin_update"
  ON public.hospitals FOR UPDATE
  USING (id = public.get_user_hospital_id() AND public.get_user_role() = 'admin')
  WITH CHECK (id = public.get_user_hospital_id() AND public.get_user_role() = 'admin');

-- --------------------------------------------------------------------------
-- POLICY: users
-- Users can see other users in the same hospital.
-- Admins can create/update users within their hospital.
-- --------------------------------------------------------------------------
CREATE POLICY "users_select_same_hospital"
  ON public.users FOR SELECT
  USING (hospital_id = public.get_user_hospital_id());

CREATE POLICY "users_admin_insert"
  ON public.users FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.auth_id = auth.uid()
        AND u.role = 'admin'
        AND u.hospital_id = hospital_id
    )
  );

CREATE POLICY "users_admin_update"
  ON public.users FOR UPDATE
  USING (hospital_id = public.get_user_hospital_id() AND public.get_user_role() = 'admin')
  WITH CHECK (hospital_id = public.get_user_hospital_id() AND public.get_user_role() = 'admin');

-- Allow new users to insert their own profile during signup
CREATE POLICY "users_self_insert"
  ON public.users FOR INSERT
  WITH CHECK (auth_id = auth.uid());

-- Allow users to update their own profile (e.g., phone, name)
CREATE POLICY "users_self_update"
  ON public.users FOR UPDATE
  USING (auth_id = auth.uid())
  WITH CHECK (auth_id = auth.uid());

-- --------------------------------------------------------------------------
-- POLICY: patients
-- Patients are visible to all users in the hospital that has an admission for them.
-- Scoped via admissions -> hospital_id. For simplicity, all authenticated users
-- in the hospital can SELECT/INSERT/UPDATE patients.
-- --------------------------------------------------------------------------
CREATE POLICY "patients_select_hospital"
  ON public.patients FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.patient_id = patients.id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "patients_insert_authenticated"
  ON public.patients FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "patients_update_hospital"
  ON public.patients FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.patient_id = patients.id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

-- --------------------------------------------------------------------------
-- POLICY: syndrome_protocols
-- Global reference data: readable by all authenticated users.
-- Only admins can create/update protocols.
-- --------------------------------------------------------------------------
CREATE POLICY "syndrome_protocols_select_all"
  ON public.syndrome_protocols FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "syndrome_protocols_admin_insert"
  ON public.syndrome_protocols FOR INSERT
  WITH CHECK (public.get_user_role() = 'admin');

CREATE POLICY "syndrome_protocols_admin_update"
  ON public.syndrome_protocols FOR UPDATE
  USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

-- --------------------------------------------------------------------------
-- POLICY: admissions
-- Scoped to the user's hospital. All hospital staff can view.
-- Insert/update limited to authenticated hospital staff.
-- --------------------------------------------------------------------------
CREATE POLICY "admissions_select_hospital"
  ON public.admissions FOR SELECT
  USING (hospital_id = public.get_user_hospital_id());

CREATE POLICY "admissions_insert_hospital"
  ON public.admissions FOR INSERT
  WITH CHECK (hospital_id = public.get_user_hospital_id());

CREATE POLICY "admissions_update_hospital"
  ON public.admissions FOR UPDATE
  USING (hospital_id = public.get_user_hospital_id())
  WITH CHECK (hospital_id = public.get_user_hospital_id());

-- --------------------------------------------------------------------------
-- POLICY: admission_syndromes
-- Inherits hospital scope through the parent admission.
-- --------------------------------------------------------------------------
CREATE POLICY "admission_syndromes_select"
  ON public.admission_syndromes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = admission_syndromes.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "admission_syndromes_insert"
  ON public.admission_syndromes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = admission_syndromes.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "admission_syndromes_update"
  ON public.admission_syndromes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = admission_syndromes.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "admission_syndromes_delete"
  ON public.admission_syndromes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = admission_syndromes.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

-- --------------------------------------------------------------------------
-- POLICY: doctor_template_overrides
-- Doctors can manage their own overrides. Admins can view all in hospital.
-- --------------------------------------------------------------------------
CREATE POLICY "doctor_overrides_select_own"
  ON public.doctor_template_overrides FOR SELECT
  USING (
    doctor_id IN (
      SELECT id FROM public.users
      WHERE auth_id = auth.uid()
    )
    OR public.get_user_role() = 'admin'
  );

CREATE POLICY "doctor_overrides_insert_own"
  ON public.doctor_template_overrides FOR INSERT
  WITH CHECK (
    doctor_id IN (
      SELECT id FROM public.users
      WHERE auth_id = auth.uid()
    )
  );

CREATE POLICY "doctor_overrides_update_own"
  ON public.doctor_template_overrides FOR UPDATE
  USING (
    doctor_id IN (
      SELECT id FROM public.users
      WHERE auth_id = auth.uid()
    )
  );

CREATE POLICY "doctor_overrides_delete_own"
  ON public.doctor_template_overrides FOR DELETE
  USING (
    doctor_id IN (
      SELECT id FROM public.users
      WHERE auth_id = auth.uid()
    )
  );

-- --------------------------------------------------------------------------
-- POLICY: workup_items
-- Scoped through the parent admission's hospital.
-- --------------------------------------------------------------------------
CREATE POLICY "workup_items_select"
  ON public.workup_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = workup_items.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "workup_items_insert"
  ON public.workup_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = workup_items.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "workup_items_update"
  ON public.workup_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = workup_items.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "workup_items_delete"
  ON public.workup_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = workup_items.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

-- --------------------------------------------------------------------------
-- POLICY: orders
-- Scoped through the parent admission's hospital.
-- --------------------------------------------------------------------------
CREATE POLICY "orders_select"
  ON public.orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = orders.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "orders_insert"
  ON public.orders FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = orders.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "orders_update"
  ON public.orders FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = orders.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

-- --------------------------------------------------------------------------
-- POLICY: scheme_packages
-- Global reference data: readable by all, admin-only write.
-- --------------------------------------------------------------------------
CREATE POLICY "scheme_packages_select_all"
  ON public.scheme_packages FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "scheme_packages_admin_insert"
  ON public.scheme_packages FOR INSERT
  WITH CHECK (public.get_user_role() = 'admin');

CREATE POLICY "scheme_packages_admin_update"
  ON public.scheme_packages FOR UPDATE
  USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

-- --------------------------------------------------------------------------
-- POLICY: reminders
-- Scoped through admission's hospital. Target user can acknowledge.
-- --------------------------------------------------------------------------
CREATE POLICY "reminders_select"
  ON public.reminders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = reminders.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "reminders_insert"
  ON public.reminders FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.admissions a
      WHERE a.id = reminders.admission_id
        AND a.hospital_id = public.get_user_hospital_id()
    )
  );

CREATE POLICY "reminders_update_target_user"
  ON public.reminders FOR UPDATE
  USING (
    target_user_id IN (
      SELECT id FROM public.users WHERE auth_id = auth.uid()
    )
    OR public.get_user_role() = 'admin'
  );

-- --------------------------------------------------------------------------
-- POLICY: guideline_updates
-- Readable by all authenticated users. Only admins can modify.
-- --------------------------------------------------------------------------
CREATE POLICY "guideline_updates_select_all"
  ON public.guideline_updates FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "guideline_updates_admin_insert"
  ON public.guideline_updates FOR INSERT
  WITH CHECK (public.get_user_role() = 'admin');

CREATE POLICY "guideline_updates_admin_update"
  ON public.guideline_updates FOR UPDATE
  USING (public.get_user_role() = 'admin')
  WITH CHECK (public.get_user_role() = 'admin');

-- --------------------------------------------------------------------------
-- POLICY: audit_log
-- Insert-only for all authenticated users (any mutation should log).
-- Select limited to admins only for compliance review.
-- --------------------------------------------------------------------------
CREATE POLICY "audit_log_insert_all"
  ON public.audit_log FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "audit_log_select_admin"
  ON public.audit_log FOR SELECT
  USING (public.get_user_role() = 'admin');

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
