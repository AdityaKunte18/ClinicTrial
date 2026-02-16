-- ============================================================================
-- ClinicalPilot: Seed Data - Scheme Packages (MJPJAY / PMJAY)
-- Run AFTER 001_initial_schema.sql and seed_syndrome_protocols.sql
-- ============================================================================

-- MJPJAY Packages (Maharashtra Govt Scheme)
INSERT INTO public.scheme_packages (id, scheme, specialty_code, package_code, package_name, package_amount, government_reserved, prerequisites, linked_syndromes, is_active, version)
VALUES
  ('00000000-0000-0000-0002-000000000001', 'mjpjay', 'MED', 'MJP-MED-001', 'Fever Workup & Management', 15000, true,
   '{"documents": ["Aadhaar/ration card", "Hospital referral letter"], "investigations": ["CBC", "Blood culture", "Malarial smear"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000001']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000002', 'mjpjay', 'MED', 'MJP-MED-002', 'Respiratory Disease Management', 20000, true,
   '{"documents": ["Aadhaar/ration card", "Hospital referral letter"], "investigations": ["Chest X-ray", "Sputum AFB", "ABG"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000002']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000003', 'mjpjay', 'MED', 'MJP-MED-003', 'CKD Management & Dialysis Initiation', 30000, true,
   '{"documents": ["Aadhaar/ration card", "Nephrology referral"], "investigations": ["RFT serial", "USG KUB", "AV fistula assessment"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000008']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000004', 'mjpjay', 'MED', 'MJP-MED-004', 'GI Bleed / Liver Disease Management', 25000, true,
   '{"documents": ["Aadhaar/ration card", "Hospital referral letter"], "investigations": ["Upper GI Endoscopy", "USG Abdomen", "PT/INR"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000006']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000005', 'mjpjay', 'MED', 'MJP-MED-005', 'Hematology Workup & Transfusion', 18000, true,
   '{"documents": ["Aadhaar/ration card"], "investigations": ["CBC", "Peripheral smear", "Iron studies"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000012']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000006', 'mjpjay', 'MED', 'MJP-MED-006', 'Cardiac Emergency Management', 35000, true,
   '{"documents": ["Aadhaar/ration card", "Cardiology referral"], "investigations": ["ECG", "Troponin", "2D Echo"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0001-000000000004']::uuid[], true, 1)

ON CONFLICT (id) DO NOTHING;

-- PMJAY (Ayushman Bharat) Packages
INSERT INTO public.scheme_packages (id, scheme, specialty_code, package_code, package_name, package_amount, government_reserved, prerequisites, linked_syndromes, is_active, version)
VALUES
  ('00000000-0000-0000-0002-000000000101', 'pmjay', 'MED', 'PM-MED-001', 'Medical Management of Fever/Infection', 12000, false,
   '{"documents": ["Ayushman Bharat card", "Hospital ID"], "investigations": ["CBC", "Blood culture"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000001']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000102', 'pmjay', 'MED', 'PM-MED-002', 'Respiratory Disease Package', 18000, false,
   '{"documents": ["Ayushman Bharat card", "Hospital ID"], "investigations": ["Chest X-ray", "Sputum AFB"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000002']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000103', 'pmjay', 'NEPH', 'PM-NEPH-001', 'Hemodialysis Sessions (12 per month)', 60000, false,
   '{"documents": ["Ayushman Bharat card", "Nephrologist prescription"], "investigations": ["RFT", "Viral markers"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000008']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000104', 'pmjay', 'MED', 'PM-MED-003', 'Liver Disease Management', 22000, false,
   '{"documents": ["Ayushman Bharat card", "Hospital ID"], "investigations": ["LFT", "USG Abdomen", "Upper GI Endoscopy"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000006']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000105', 'pmjay', 'MED', 'PM-MED-004', 'Poisoning Management', 10000, false,
   '{"documents": ["Ayushman Bharat card", "Hospital ID"], "investigations": ["Toxicology screen", "RFT", "LFT"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000014']::uuid[], true, 1),

  ('00000000-0000-0000-0002-000000000106', 'pmjay', 'MED', 'PM-MED-005', 'Sepsis/Shock Management', 25000, false,
   '{"documents": ["Ayushman Bharat card", "Hospital ID"], "investigations": ["Blood cultures", "Lactate", "Procalcitonin"]}'::jsonb,
   ARRAY['00000000-0000-0000-0001-000000000015']::uuid[], true, 1)

ON CONFLICT (id) DO NOTHING;
