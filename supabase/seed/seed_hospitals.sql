-- ============================================================================
-- ClinicalPilot: Seed Data - Hospitals
-- Run AFTER 001_initial_schema.sql
-- ============================================================================

INSERT INTO public.hospitals (id, name, city, type, mjpjay_empanelled, pmjay_empanelled)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Government Medical College & Hospital',
  'Pune',
  'government',
  true,
  true
)
ON CONFLICT (id) DO NOTHING;
