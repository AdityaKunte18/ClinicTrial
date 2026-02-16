-- ============================================================================
-- ClinicalPilot: Seed Data - Syndrome Protocols
-- Run AFTER 001_initial_schema.sql and seed_hospitals.sql
-- ============================================================================

-- Helper: wraps each INSERT in ON CONFLICT DO NOTHING for idempotency.
-- IDs are deterministic UUIDs keyed off syndrome number.

-- SYN-01: Fever / Infectious Diseases
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000001',
  'SYN-01-FEVER',
  'Fever / Infectious Diseases',
  'Infectious / Systemic',
  1, true,
  '{
    "history": [
      {"id": "f-h1", "text": "Duration, pattern (continuous/intermittent/remittent)", "required": true},
      {"id": "f-h2", "text": "Travel history & endemic area exposure", "required": true},
      {"id": "f-h3", "text": "Contact history (TB, COVID)", "required": true},
      {"id": "f-h4", "text": "Animal/insect exposure (lepto, scrub typhus)", "required": false}
    ],
    "examination": [
      {"id": "f-e1", "text": "Vitals including postural BP", "required": true},
      {"id": "f-e2", "text": "Hepatosplenomegaly", "required": true},
      {"id": "f-e3", "text": "Eschar search (axilla, groin, hairline)", "required": true}
    ],
    "blood_investigations": [
      {"id": "f-b1", "text": "CBC with differential", "day": 1, "category": "Baseline", "required": true},
      {"id": "f-b2", "text": "RFT, LFT, Electrolytes", "day": 1, "category": "Baseline", "required": true},
      {"id": "f-b3", "text": "Malarial antigen + peripheral smear", "day": 1, "category": "Fever-Specific", "required": true},
      {"id": "f-b4", "text": "Dengue NS1 + IgM/IgG", "day": 1, "category": "Fever-Specific", "required": true},
      {"id": "f-b5", "text": "Blood culture x2 (before antibiotics)", "day": 1, "category": "Fever-Specific", "required": true},
      {"id": "f-b6", "text": "Widal test", "day": 1, "category": "Fever-Specific", "required": false},
      {"id": "f-b7", "text": "Scrub typhus IgM", "day": 1, "category": "Tropical Panel", "required": false}
    ],
    "radiology": [
      {"id": "f-r1", "text": "Chest X-ray PA", "day": 1, "required": true},
      {"id": "f-r2", "text": "USG Abdomen", "day": 2, "required": false}
    ],
    "treatment_orders": [
      {"id": "f-t1", "text": "IV fluids per protocol", "required": true},
      {"id": "f-t2", "text": "Paracetamol 650mg SOS (avoid NSAIDs in dengue)", "required": true},
      {"id": "f-t3", "text": "Empiric: Inj Ceftriaxone 2g IV OD", "required": false}
    ],
    "referrals": [
      {"id": "f-ref1", "text": "Infectious Disease specialist (if PUO >14 days)", "required": false}
    ],
    "scheme_packages": [],
    "discharge_criteria": [
      {"id": "f-dc1", "text": "Blood cultures final result reviewed", "hard_block": true},
      {"id": "f-dc2", "text": "Source of fever identified OR follow-up plan documented", "hard_block": true},
      {"id": "f-dc3", "text": "Afebrile for 48 hours", "hard_block": false}
    ]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-02: Respiratory Syndromes
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000002',
  'SYN-02-RESPIRATORY',
  'Respiratory Syndromes',
  'Respiratory',
  1, true,
  '{
    "history": [
      {"id": "r-h1", "text": "Duration and progression of dyspnea", "required": true},
      {"id": "r-h2", "text": "Cough — productive/dry, sputum, hemoptysis", "required": true},
      {"id": "r-h3", "text": "Smoking history (pack-years)", "required": true},
      {"id": "r-h4", "text": "Prior TB history, MDR risk factors", "required": true}
    ],
    "examination": [
      {"id": "r-e1", "text": "SpO2 on room air and supplemental O2", "required": true},
      {"id": "r-e2", "text": "Respiratory rate, accessory muscle use", "required": true},
      {"id": "r-e3", "text": "Auscultation — air entry, wheeze, creps", "required": true}
    ],
    "blood_investigations": [
      {"id": "r-b1", "text": "CBC, RFT, LFT, Electrolytes", "day": 1, "category": "Baseline", "required": true},
      {"id": "r-b2", "text": "ABG", "day": 1, "category": "Baseline", "required": true},
      {"id": "r-b3", "text": "Sputum AFB smear + CBNAAT", "day": 1, "category": "Respiratory-Specific", "required": true},
      {"id": "r-b4", "text": "Procalcitonin", "day": 1, "category": "Respiratory-Specific", "required": false},
      {"id": "r-b5", "text": "NT-proBNP (if HF suspected)", "day": 1, "category": "Respiratory-Specific", "required": false}
    ],
    "radiology": [
      {"id": "r-r1", "text": "Chest X-ray PA", "day": 1, "required": true},
      {"id": "r-r2", "text": "HRCT Thorax (if CXR inconclusive)", "day": 2, "required": false}
    ],
    "treatment_orders": [
      {"id": "r-t1", "text": "O2 therapy to maintain SpO2 >92%", "required": true},
      {"id": "r-t2", "text": "Nebulization PRN", "required": false},
      {"id": "r-t3", "text": "Empiric antibiotics per CURB-65", "required": false}
    ],
    "referrals": [
      {"id": "r-ref1", "text": "Pulmonology opinion for non-resolving infiltrates", "required": false}
    ],
    "scheme_packages": [],
    "discharge_criteria": [
      {"id": "r-dc1", "text": "SpO2 >92% on room air for 24 hours", "hard_block": true},
      {"id": "r-dc2", "text": "Sputum AFB result reviewed", "hard_block": true},
      {"id": "r-dc3", "text": "Oral stepdown antibiotics tolerated", "hard_block": false}
    ]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-03: Acute Coronary Syndrome
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000003',
  'SYN-03-ACS',
  'Acute Coronary Syndrome',
  'Cardiovascular',
  1, true,
  '{
    "history": [{"id": "acs-h1", "text": "Chest pain onset, character, radiation, duration", "required": true}],
    "examination": [{"id": "acs-e1", "text": "Hemodynamic assessment, JVP, heart sounds", "required": true}],
    "blood_investigations": [{"id": "acs-b1", "text": "Troponin I/T, ECG, CBC, RFT", "day": 1, "required": true}],
    "radiology": [{"id": "acs-r1", "text": "Chest X-ray, 2D Echo", "day": 1, "required": true}],
    "treatment_orders": [{"id": "acs-t1", "text": "MONA protocol + anticoagulation", "required": true}],
    "referrals": [{"id": "acs-ref1", "text": "Cardiology for cath lab", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "acs-dc1", "text": "Cardiac biomarkers trending down, hemodynamically stable", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-04: Heart Failure
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000004',
  'SYN-04-HF',
  'Heart Failure',
  'Cardiovascular',
  1, true,
  '{
    "history": [{"id": "hf-h1", "text": "NYHA class, orthopnea, PND, weight gain", "required": true}],
    "examination": [{"id": "hf-e1", "text": "JVP, pedal edema, S3 gallop, lung creps", "required": true}],
    "blood_investigations": [{"id": "hf-b1", "text": "NT-proBNP, CBC, RFT, LFT, Electrolytes, TSH", "day": 1, "required": true}],
    "radiology": [{"id": "hf-r1", "text": "Chest X-ray, 2D Echo with EF", "day": 1, "required": true}],
    "treatment_orders": [{"id": "hf-t1", "text": "IV Furosemide, ACEi/ARB, Beta-blocker titration", "required": true}],
    "referrals": [{"id": "hf-ref1", "text": "Cardiology for device/surgery evaluation", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "hf-dc1", "text": "Euvolemic, tolerating oral diuretics, EF documented", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-05: Hypertensive Emergency
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000005',
  'SYN-05-HTN',
  'Hypertensive Emergency',
  'Cardiovascular',
  1, true,
  '{
    "history": [{"id": "htn-h1", "text": "BP readings, medication compliance, headache, visual changes", "required": true}],
    "examination": [{"id": "htn-e1", "text": "Fundoscopy, neurological exam, cardiac exam", "required": true}],
    "blood_investigations": [{"id": "htn-b1", "text": "RFT, Electrolytes, CBC, urine routine", "day": 1, "required": true}],
    "radiology": [{"id": "htn-r1", "text": "CT Brain if neurological deficit, Chest X-ray", "day": 1, "required": true}],
    "treatment_orders": [{"id": "htn-t1", "text": "IV Labetalol/Nitroglycerin, target 25% reduction in 1 hr", "required": true}],
    "referrals": [{"id": "htn-ref1", "text": "Nephrology if renal impairment", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "htn-dc1", "text": "BP controlled on oral agents, end-organ function stable", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-06: GI / Hepatology
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000006',
  'SYN-06-GI-HEPATOLOGY',
  'GI / Hepatology (CLD, Cirrhosis, GI Bleed)',
  'GI / Hepatology',
  1, true,
  '{
    "history": [
      {"id": "gi-h1", "text": "Alcohol intake (grams/day, duration)", "required": true},
      {"id": "gi-h2", "text": "Jaundice, abdominal distension, hematemesis/melena", "required": true},
      {"id": "gi-h3", "text": "Prior variceal bleed, encephalopathy episodes", "required": true}
    ],
    "examination": [
      {"id": "gi-e1", "text": "Icterus, spider naevi, palmar erythema", "required": true},
      {"id": "gi-e2", "text": "Ascites (shifting dullness, fluid thrill)", "required": true},
      {"id": "gi-e3", "text": "Hepatic encephalopathy grading", "required": true}
    ],
    "blood_investigations": [
      {"id": "gi-b1", "text": "CBC, RFT, LFT, PT/INR, Electrolytes", "day": 1, "category": "Baseline", "required": true},
      {"id": "gi-b2", "text": "HBsAg, Anti-HCV", "day": 1, "category": "Etiology", "required": true},
      {"id": "gi-b3", "text": "Ascitic fluid analysis (albumin, cell count, culture)", "day": 1, "category": "Complications", "required": true},
      {"id": "gi-b4", "text": "AFP (if cirrhosis)", "day": 2, "category": "Screening", "required": false}
    ],
    "radiology": [
      {"id": "gi-r1", "text": "USG Abdomen with Doppler", "day": 1, "required": true},
      {"id": "gi-r2", "text": "Upper GI Endoscopy (variceal grading)", "day": 2, "required": true}
    ],
    "treatment_orders": [
      {"id": "gi-t1", "text": "IV Octreotide/Terlipressin (if variceal bleed)", "required": false},
      {"id": "gi-t2", "text": "Lactulose + Rifaximin (if encephalopathy)", "required": false},
      {"id": "gi-t3", "text": "Salt restriction + Spironolactone (ascites)", "required": false}
    ],
    "referrals": [
      {"id": "gi-ref1", "text": "GI for endoscopy/banding", "required": false}
    ],
    "scheme_packages": [],
    "discharge_criteria": [
      {"id": "gi-dc1", "text": "No active GI bleed for 48 hours", "hard_block": true},
      {"id": "gi-dc2", "text": "INR improving trend", "hard_block": true},
      {"id": "gi-dc3", "text": "Encephalopathy resolved or at baseline", "hard_block": false}
    ]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-07: AKI / Renal Emergency
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000007',
  'SYN-07-AKI',
  'Acute Kidney Injury',
  'Renal',
  1, true,
  '{
    "history": [{"id": "aki-h1", "text": "Urine output, nephrotoxin exposure, volume status", "required": true}],
    "examination": [{"id": "aki-e1", "text": "Volume assessment, edema, BP, JVP", "required": true}],
    "blood_investigations": [{"id": "aki-b1", "text": "RFT serial, Electrolytes, ABG, urine routine + microscopy", "day": 1, "required": true}],
    "radiology": [{"id": "aki-r1", "text": "USG KUB to rule out obstruction", "day": 1, "required": true}],
    "treatment_orders": [{"id": "aki-t1", "text": "Fluid challenge or restriction based on etiology", "required": true}],
    "referrals": [{"id": "aki-ref1", "text": "Nephrology for dialysis assessment", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "aki-dc1", "text": "Creatinine trending down, adequate urine output", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-08: CKD Management
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000008',
  'SYN-08-CKD',
  'CKD Management',
  'Renal',
  1, true,
  '{
    "history": [
      {"id": "ckd-h1", "text": "Known CKD stage, baseline creatinine", "required": true},
      {"id": "ckd-h2", "text": "Dialysis status (HD/PD/pre-dialysis)", "required": true},
      {"id": "ckd-h3", "text": "Medication compliance, dietary adherence", "required": true}
    ],
    "examination": [
      {"id": "ckd-e1", "text": "Volume status, edema, AV fistula check", "required": true},
      {"id": "ckd-e2", "text": "BP measurement (sitting, standing)", "required": true}
    ],
    "blood_investigations": [
      {"id": "ckd-b1", "text": "CBC, RFT, Electrolytes, Calcium/Phosphate", "day": 1, "category": "Baseline", "required": true},
      {"id": "ckd-b2", "text": "Iron studies, Vitamin B12, Folate", "day": 1, "category": "Anemia Workup", "required": true},
      {"id": "ckd-b3", "text": "PTH, Vitamin D", "day": 2, "category": "Bone Mineral", "required": false},
      {"id": "ckd-b4", "text": "HbA1c (if diabetic)", "day": 1, "category": "Etiology", "required": false},
      {"id": "ckd-b5", "text": "Urine protein/creatinine ratio", "day": 1, "category": "Baseline", "required": true}
    ],
    "radiology": [
      {"id": "ckd-r1", "text": "USG KUB (kidney size, echogenicity)", "day": 1, "required": true}
    ],
    "treatment_orders": [
      {"id": "ckd-t1", "text": "ACEi/ARB for proteinuria", "required": true},
      {"id": "ckd-t2", "text": "EPO + Iron supplementation (if Hb <10)", "required": false},
      {"id": "ckd-t3", "text": "Phosphate binder, Calcitriol", "required": false}
    ],
    "referrals": [
      {"id": "ckd-ref1", "text": "Nephrology for dialysis access planning", "required": false}
    ],
    "scheme_packages": [],
    "discharge_criteria": [
      {"id": "ckd-dc1", "text": "Electrolytes stable, no uremic symptoms", "hard_block": true},
      {"id": "ckd-dc2", "text": "Dialysis access functional (if applicable)", "hard_block": true},
      {"id": "ckd-dc3", "text": "Follow-up nephrology appointment scheduled", "hard_block": false}
    ]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-09: Electrolyte Disorders
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000009',
  'SYN-09-ELECTROLYTE',
  'Electrolyte Disorders',
  'Renal / Metabolic',
  1, true,
  '{
    "history": [{"id": "el-h1", "text": "Symptoms: weakness, cramps, altered sensorium, palpitations", "required": true}],
    "examination": [{"id": "el-e1", "text": "Neurological exam, ECG changes correlation", "required": true}],
    "blood_investigations": [{"id": "el-b1", "text": "Serum Na/K/Ca/Mg/Phosphate, ABG, RFT", "day": 1, "required": true}],
    "radiology": [{"id": "el-r1", "text": "ECG (for hyperkalemia/hypocalcemia)", "day": 1, "required": true}],
    "treatment_orders": [{"id": "el-t1", "text": "Correction per protocol based on specific electrolyte", "required": true}],
    "referrals": [{"id": "el-ref1", "text": "Endocrinology if recurrent/refractory", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "el-dc1", "text": "Electrolytes within safe range for 24 hours", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-10: Neurological Syndromes
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000010',
  'SYN-10-NEURO',
  'Neurological Syndromes',
  'Neurology',
  1, true,
  '{
    "history": [{"id": "n-h1", "text": "Onset, progression, focal deficits, seizures, headache, GCS", "required": true}],
    "examination": [{"id": "n-e1", "text": "GCS, pupillary reaction, motor power, reflexes, cerebellar signs", "required": true}],
    "blood_investigations": [{"id": "n-b1", "text": "CBC, RFT, Electrolytes, Blood sugar, PT/INR", "day": 1, "required": true}],
    "radiology": [{"id": "n-r1", "text": "CT Brain plain (MRI if indicated)", "day": 1, "required": true}],
    "treatment_orders": [{"id": "n-t1", "text": "Anti-epileptics / thrombolysis / supportive per diagnosis", "required": true}],
    "referrals": [{"id": "n-ref1", "text": "Neurology / Neurosurgery", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "n-dc1", "text": "Neurologically stable, seizure-free 48 hours, imaging reviewed", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-11: Endocrine (DKA / Thyroid Crisis)
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000011',
  'SYN-11-ENDOCRINE',
  'Endocrine Emergencies (DKA / Thyroid Crisis)',
  'Endocrine',
  1, true,
  '{
    "history": [{"id": "end-h1", "text": "Diabetes history, insulin compliance, polyuria, weight loss, tremor", "required": true}],
    "examination": [{"id": "end-e1", "text": "Dehydration assessment, Kussmaul breathing, thyroid exam", "required": true}],
    "blood_investigations": [{"id": "end-b1", "text": "Blood sugar serial, HbA1c, ABG, Electrolytes, TSH/FT4", "day": 1, "required": true}],
    "radiology": [{"id": "end-r1", "text": "Chest X-ray (infection screen)", "day": 1, "required": false}],
    "treatment_orders": [{"id": "end-t1", "text": "DKA protocol (insulin drip + fluids) / anti-thyroid drugs", "required": true}],
    "referrals": [{"id": "end-ref1", "text": "Endocrinology", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "end-dc1", "text": "Anion gap closed, tolerating SC insulin / Thyroid hormones stable", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-12: Hematology
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000012',
  'SYN-12-HEMATOLOGY',
  'Hematology (Anemia, Pancytopenia, Bleeding)',
  'Hematology',
  1, true,
  '{
    "history": [
      {"id": "hem-h1", "text": "Fatigue, pallor, bleeding (site, duration)", "required": true},
      {"id": "hem-h2", "text": "Drug history (methotrexate, chemo, anticoagulants)", "required": true},
      {"id": "hem-h3", "text": "Dietary history (vegetarian, malnutrition)", "required": true}
    ],
    "examination": [
      {"id": "hem-e1", "text": "Pallor, petechiae, ecchymoses, lymphadenopathy", "required": true},
      {"id": "hem-e2", "text": "Hepatosplenomegaly", "required": true}
    ],
    "blood_investigations": [
      {"id": "hem-b1", "text": "CBC with reticulocyte count", "day": 1, "category": "Baseline", "required": true},
      {"id": "hem-b2", "text": "Peripheral smear", "day": 1, "category": "Baseline", "required": true},
      {"id": "hem-b3", "text": "Iron studies, B12, Folate, LDH, Haptoglobin", "day": 1, "category": "Anemia Workup", "required": true},
      {"id": "hem-b4", "text": "PT/INR, aPTT, Fibrinogen, D-dimer", "day": 1, "category": "Coagulation", "required": true},
      {"id": "hem-b5", "text": "Bone marrow biopsy (if pancytopenia)", "day": 3, "category": "Advanced", "required": false}
    ],
    "radiology": [
      {"id": "hem-r1", "text": "USG Abdomen (spleen size)", "day": 1, "required": false}
    ],
    "treatment_orders": [
      {"id": "hem-t1", "text": "Packed RBC transfusion if Hb <7 (or symptomatic)", "required": false},
      {"id": "hem-t2", "text": "Platelet transfusion if <10,000 or active bleeding", "required": false},
      {"id": "hem-t3", "text": "IV Iron / B12 / Folate supplementation as indicated", "required": false}
    ],
    "referrals": [
      {"id": "hem-ref1", "text": "Hematology for bone marrow evaluation", "required": false}
    ],
    "scheme_packages": [],
    "discharge_criteria": [
      {"id": "hem-dc1", "text": "Hemoglobin stable, no active bleeding", "hard_block": true},
      {"id": "hem-dc2", "text": "Bone marrow report reviewed (if done)", "hard_block": true},
      {"id": "hem-dc3", "text": "Transfusion-free for 24 hours", "hard_block": false}
    ]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-13: Rheumatology / Autoimmune
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000013',
  'SYN-13-RHEUMATOLOGY',
  'Rheumatology / Autoimmune',
  'Rheumatology',
  1, true,
  '{
    "history": [{"id": "rh-h1", "text": "Joint pain pattern, rash, photosensitivity, oral ulcers, Raynaud", "required": true}],
    "examination": [{"id": "rh-e1", "text": "Joint exam, skin lesions, malar rash, lymphadenopathy", "required": true}],
    "blood_investigations": [{"id": "rh-b1", "text": "CBC, ESR, CRP, ANA, dsDNA, C3/C4, RF, Anti-CCP", "day": 1, "required": true}],
    "radiology": [{"id": "rh-r1", "text": "X-ray affected joints, Chest X-ray", "day": 1, "required": false}],
    "treatment_orders": [{"id": "rh-t1", "text": "NSAIDs / Steroids / DMARDs per diagnosis", "required": true}],
    "referrals": [{"id": "rh-ref1", "text": "Rheumatology", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "rh-dc1", "text": "Inflammatory markers trending down, pain controlled", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-14: Poisoning / Toxicology
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000014',
  'SYN-14-POISONING',
  'Poisoning / Toxicology',
  'Emergency',
  1, true,
  '{
    "history": [{"id": "poi-h1", "text": "Substance, amount, time of ingestion, intent, vomiting", "required": true}],
    "examination": [{"id": "poi-e1", "text": "GCS, pupil size, vitals, toxidrome identification", "required": true}],
    "blood_investigations": [{"id": "poi-b1", "text": "CBC, RFT, LFT, ABG, Cholinesterase (if OP), Paracetamol/Salicylate levels", "day": 1, "required": true}],
    "radiology": [{"id": "poi-r1", "text": "X-ray Abdomen (if radiopaque substance)", "day": 1, "required": false}],
    "treatment_orders": [{"id": "poi-t1", "text": "Decontamination (gastric lavage/activated charcoal) + specific antidote", "required": true}],
    "referrals": [{"id": "poi-ref1", "text": "Psychiatry evaluation (if intentional)", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "poi-dc1", "text": "Medically stable, psychiatry clearance (if intentional), safe discharge plan", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-15: Shock / Sepsis
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000015',
  'SYN-15-SHOCK',
  'Shock / Sepsis',
  'Critical Care',
  1, true,
  '{
    "history": [{"id": "sh-h1", "text": "Source of infection, onset, prior antibiotics, comorbidities", "required": true}],
    "examination": [{"id": "sh-e1", "text": "MAP, cap refill, urine output, lactate, qSOFA", "required": true}],
    "blood_investigations": [{"id": "sh-b1", "text": "CBC, RFT, LFT, Lactate, Procalcitonin, Blood cultures x2, ABG", "day": 1, "required": true}],
    "radiology": [{"id": "sh-r1", "text": "Chest X-ray, POCUS (IVC, cardiac), source-specific imaging", "day": 1, "required": true}],
    "treatment_orders": [{"id": "sh-t1", "text": "Surviving Sepsis: 30mL/kg crystalloid, vasopressors, broad-spectrum antibiotics within 1 hour", "required": true}],
    "referrals": [{"id": "sh-ref1", "text": "ICU/Critical Care", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "sh-dc1", "text": "Off vasopressors >24h, source control achieved, cultures reviewed", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-16: Nutrition / Malnutrition
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000016',
  'SYN-16-NUTRITION',
  'Nutrition / Malnutrition',
  'Nutrition',
  1, true,
  '{
    "history": [{"id": "nut-h1", "text": "Dietary intake, weight loss, appetite, socioeconomic status", "required": true}],
    "examination": [{"id": "nut-e1", "text": "BMI, edema, skin/hair changes, muscle wasting", "required": true}],
    "blood_investigations": [{"id": "nut-b1", "text": "CBC, Albumin, Prealbumin, Iron studies, B12, Folate, Electrolytes", "day": 1, "required": true}],
    "radiology": [{"id": "nut-r1", "text": "DEXA scan (if osteoporosis suspected)", "day": 3, "required": false}],
    "treatment_orders": [{"id": "nut-t1", "text": "Calorie supplementation, micronutrient correction, refeeding precautions", "required": true}],
    "referrals": [{"id": "nut-ref1", "text": "Dietitian consult", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "nut-dc1", "text": "Tolerating oral diet, electrolytes stable, follow-up plan", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-17: Oncology / Tumor Lysis / Febrile Neutropenia
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000017',
  'SYN-17-ONCOLOGY',
  'Oncology Emergencies',
  'Oncology',
  1, true,
  '{
    "history": [{"id": "onc-h1", "text": "Cancer type, chemo regimen, last cycle, ANC, fever", "required": true}],
    "examination": [{"id": "onc-e1", "text": "Vitals, mucositis, catheter site, perianal exam", "required": true}],
    "blood_investigations": [{"id": "onc-b1", "text": "CBC with ANC, RFT, LFT, Uric acid, LDH, Calcium, Phosphate, Blood cultures", "day": 1, "required": true}],
    "radiology": [{"id": "onc-r1", "text": "Chest X-ray, CT as indicated", "day": 1, "required": false}],
    "treatment_orders": [{"id": "onc-t1", "text": "Broad-spectrum antibiotics (if febrile neutropenia), IV hydration, allopurinol/rasburicase (if TLS)", "required": true}],
    "referrals": [{"id": "onc-ref1", "text": "Medical Oncology/Hematology", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "onc-dc1", "text": "ANC >500, afebrile 48h, tumor lysis labs normalizing", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-18: Psychiatry (Delirium / Acute Psychosis)
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000018',
  'SYN-18-PSYCH',
  'Psychiatry (Delirium / Acute Psychosis)',
  'Psychiatry',
  1, true,
  '{
    "history": [{"id": "psy-h1", "text": "Onset (acute vs chronic), substance use, medication changes, sleep pattern", "required": true}],
    "examination": [{"id": "psy-e1", "text": "Mental status exam, CAM score (delirium), orientation", "required": true}],
    "blood_investigations": [{"id": "psy-b1", "text": "CBC, RFT, LFT, Electrolytes, TSH, Blood sugar, B12, Ammonia", "day": 1, "required": true}],
    "radiology": [{"id": "psy-r1", "text": "CT Brain (if new-onset delirium/psychosis)", "day": 1, "required": false}],
    "treatment_orders": [{"id": "psy-t1", "text": "Treat underlying cause, low-dose Haloperidol for agitation", "required": true}],
    "referrals": [{"id": "psy-ref1", "text": "Psychiatry", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "psy-dc1", "text": "Delirium resolved or baseline mental status, psychiatry clearance", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-19: Dermatology (SJS/TEN, Erythroderma)
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000019',
  'SYN-19-DERM',
  'Dermatology (SJS/TEN, Erythroderma)',
  'Dermatology',
  1, true,
  '{
    "history": [{"id": "d-h1", "text": "Drug history (last 4 weeks), rash onset and progression, mucosal involvement", "required": true}],
    "examination": [{"id": "d-e1", "text": "BSA involved, Nikolsky sign, mucosal exam (oral, ocular, genital)", "required": true}],
    "blood_investigations": [{"id": "d-b1", "text": "CBC, RFT, LFT, Electrolytes, Blood culture, skin biopsy", "day": 1, "required": true}],
    "radiology": [{"id": "d-r1", "text": "Chest X-ray (infection screen)", "day": 1, "required": false}],
    "treatment_orders": [{"id": "d-t1", "text": "Stop offending drug, wound care, IV fluids, consider IVIG/steroids", "required": true}],
    "referrals": [{"id": "d-ref1", "text": "Dermatology, Ophthalmology (if ocular involvement)", "required": true}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "d-dc1", "text": "No new lesions, re-epithelialization begun, oral intake adequate", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- SYN-20: ICU / Critical Care Overlap
INSERT INTO public.syndrome_protocols (id, code, name, category, version, is_active, base_template)
VALUES (
  '00000000-0000-0000-0001-000000000020',
  'SYN-20-ICU',
  'ICU / Critical Care Overlap',
  'Critical Care',
  1, true,
  '{
    "history": [{"id": "icu-h1", "text": "Reason for ICU admission, ventilation status, vasopressor requirement", "required": true}],
    "examination": [{"id": "icu-e1", "text": "GCS, hemodynamics, ventilator settings, lines/drains check", "required": true}],
    "blood_investigations": [{"id": "icu-b1", "text": "CBC, RFT, LFT, ABG, Lactate, Procalcitonin, Cultures, Coagulation", "day": 1, "required": true}],
    "radiology": [{"id": "icu-r1", "text": "Portable CXR, POCUS, imaging per clinical scenario", "day": 1, "required": true}],
    "treatment_orders": [{"id": "icu-t1", "text": "Organ support: ventilation, vasopressors, RRT as needed", "required": true}],
    "referrals": [{"id": "icu-ref1", "text": "Multi-specialty as per organ involvement", "required": false}],
    "scheme_packages": [],
    "discharge_criteria": [{"id": "icu-dc1", "text": "Off vasopressors, weaned from ventilator, stable for step-down", "hard_block": true}]
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;
