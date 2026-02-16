import '../models/models.dart';

/// All 20 syndrome protocols. 5 detailed, 15 stubs.
class SyndromeSeedData {
  static List<SyndromeProtocol> get allProtocols => [
    _fever, _respiratory, _acs, _hf, _htnEmergency,
    _giHepatology, _aki, _ckd, _electrolyte, _neuro,
    _endocrine, _hematology, _rheumatology, _poisoning, _shock,
    _nutrition, _oncology, _psych, _derm, _icu,
  ];

  // ── DETAILED: Fever ──────────────────────────────────────────────
  static final _fever = SyndromeProtocol(
    id: 'syn-01', code: 'SYN-01-FEVER',
    name: 'Fever / Infectious Diseases',
    category: 'Infectious / Systemic', version: 1, isActive: true,
    baseTemplate: {
      'history': [
        {'id': 'f-h1', 'text': 'Duration, pattern (continuous/intermittent/remittent)', 'required': true},
        {'id': 'f-h2', 'text': 'Travel history & endemic area exposure', 'required': true},
        {'id': 'f-h3', 'text': 'Contact history (TB, COVID)', 'required': true},
        {'id': 'f-h4', 'text': 'Animal/insect exposure (lepto, scrub typhus)', 'required': false},
      ],
      'examination': [
        {'id': 'f-e1', 'text': 'Vitals including postural BP', 'required': true},
        {'id': 'f-e2', 'text': 'Hepatosplenomegaly', 'required': true},
        {'id': 'f-e3', 'text': 'Eschar search (axilla, groin, hairline)', 'required': true},
      ],
      'blood_investigations': [
        {'id': 'f-b1', 'text': 'CBC with differential', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'f-b2', 'text': 'RFT, LFT, Electrolytes', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'f-b3', 'text': 'Malarial antigen + peripheral smear', 'day': 1, 'category': 'Fever-Specific', 'required': true},
        {'id': 'f-b4', 'text': 'Dengue NS1 + IgM/IgG', 'day': 1, 'category': 'Fever-Specific', 'required': true},
        {'id': 'f-b5', 'text': 'Blood culture x2 (before antibiotics)', 'day': 1, 'category': 'Fever-Specific', 'required': true},
        {'id': 'f-b6', 'text': 'Widal test', 'day': 1, 'category': 'Fever-Specific', 'required': false},
        {'id': 'f-b7', 'text': 'Scrub typhus IgM', 'day': 1, 'category': 'Tropical Panel', 'required': false},
      ],
      'radiology': [
        {'id': 'f-r1', 'text': 'Chest X-ray PA', 'day': 1, 'required': true},
        {'id': 'f-r2', 'text': 'USG Abdomen', 'day': 2, 'required': false},
      ],
      'treatment_orders': [
        {'id': 'f-t1', 'text': 'IV fluids per protocol', 'required': true},
        {'id': 'f-t2', 'text': 'Paracetamol 650mg SOS (avoid NSAIDs in dengue)', 'required': true},
        {'id': 'f-t3', 'text': 'Empiric: Inj Ceftriaxone 2g IV OD', 'required': false},
      ],
      'referrals': [
        {'id': 'f-ref1', 'text': 'Infectious Disease specialist (if PUO >14 days)', 'required': false},
      ],
      'scheme_packages': [],
      'discharge_criteria': [
        {'id': 'f-dc1', 'text': 'Blood cultures final result reviewed', 'hard_block': true},
        {'id': 'f-dc2', 'text': 'Source of fever identified OR follow-up plan documented', 'hard_block': true},
        {'id': 'f-dc3', 'text': 'Afebrile for 48 hours', 'hard_block': false},
      ],
    },
    updatedAt: DateTime(2026, 1, 1),
  );

  // ── DETAILED: Respiratory ────────────────────────────────────────
  static final _respiratory = SyndromeProtocol(
    id: 'syn-02', code: 'SYN-02-RESPIRATORY',
    name: 'Respiratory Syndromes',
    category: 'Respiratory', version: 1, isActive: true,
    baseTemplate: {
      'history': [
        {'id': 'r-h1', 'text': 'Duration and progression of dyspnea', 'required': true},
        {'id': 'r-h2', 'text': 'Cough — productive/dry, sputum, hemoptysis', 'required': true},
        {'id': 'r-h3', 'text': 'Smoking history (pack-years)', 'required': true},
        {'id': 'r-h4', 'text': 'Prior TB history, MDR risk factors', 'required': true},
      ],
      'examination': [
        {'id': 'r-e1', 'text': 'SpO2 on room air and supplemental O2', 'required': true},
        {'id': 'r-e2', 'text': 'Respiratory rate, accessory muscle use', 'required': true},
        {'id': 'r-e3', 'text': 'Auscultation — air entry, wheeze, creps', 'required': true},
      ],
      'blood_investigations': [
        {'id': 'r-b1', 'text': 'CBC, RFT, LFT, Electrolytes', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'r-b2', 'text': 'ABG', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'r-b3', 'text': 'Sputum AFB smear + CBNAAT', 'day': 1, 'category': 'Respiratory-Specific', 'required': true},
        {'id': 'r-b4', 'text': 'Blood culture x2 (if pneumonia)', 'day': 1, 'category': 'Respiratory-Specific', 'required': false},
        {'id': 'r-b5', 'text': 'Procalcitonin', 'day': 1, 'category': 'Respiratory-Specific', 'required': false},
      ],
      'radiology': [
        {'id': 'r-r1', 'text': 'CXR PA view', 'day': 1, 'required': true},
        {'id': 'r-r2', 'text': 'USG Chest (effusion quantification)', 'day': 1, 'required': false},
        {'id': 'r-r3', 'text': 'HRCT Chest (if ILD/bronchiectasis suspected)', 'day': 2, 'required': false},
      ],
      'treatment_orders': [
        {'id': 'r-t1', 'text': 'O2 target SpO2 88-92% (COPD) or 94-98%', 'required': true},
        {'id': 'r-t2', 'text': 'Nebulization: Salbutamol + Ipratropium 6-8 hourly', 'required': true},
        {'id': 'r-t3', 'text': 'Antibiotics: Ceftriaxone + Azithromycin (CAP)', 'required': false},
      ],
      'referrals': [
        {'id': 'r-ref1', 'text': 'Pulmonology (ILD, unresolved effusion)', 'required': false},
      ],
      'scheme_packages': [],
      'discharge_criteria': [
        {'id': 'r-dc1', 'text': 'SpO2 >=92% on room air (or baseline)', 'hard_block': true},
        {'id': 'r-dc2', 'text': 'If TB — DOTS registration done', 'hard_block': true},
        {'id': 'r-dc3', 'text': 'Inhaler technique demonstrated (if COPD/Asthma)', 'hard_block': false},
      ],
    },
    updatedAt: DateTime(2026, 1, 1),
  );

  // ── DETAILED: GI/Hepatology ──────────────────────────────────────
  static final _giHepatology = SyndromeProtocol(
    id: 'syn-06', code: 'SYN-06-GI-HEPATOLOGY',
    name: 'GI Bleed / Hepatology / CLD',
    category: 'Gastroenterology / Hepatology', version: 1, isActive: true,
    baseTemplate: {
      'history': [
        {'id': 'g-h1', 'text': 'Hematemesis/melena — quantity, duration', 'required': true},
        {'id': 'g-h2', 'text': 'Alcohol history (type, quantity, duration)', 'required': true},
        {'id': 'g-h3', 'text': 'Known CLD — etiology, Child-Pugh, prior decompensations', 'required': true},
        {'id': 'g-h4', 'text': 'Medications (NSAIDs, anticoagulants)', 'required': true},
      ],
      'examination': [
        {'id': 'g-e1', 'text': 'Vitals, postural drop assessment', 'required': true},
        {'id': 'g-e2', 'text': 'Hepatosplenomegaly, ascites', 'required': true},
        {'id': 'g-e3', 'text': 'Stigmata of CLD (spider naevi, palmar erythema)', 'required': true},
      ],
      'blood_investigations': [
        {'id': 'g-b1', 'text': 'CBC, PT/INR, aPTT', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'g-b2', 'text': 'LFT (bilirubin, AST, ALT, ALP, albumin)', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'g-b3', 'text': 'RFT, Electrolytes', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'g-b4', 'text': 'Blood group + cross-match', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'g-b5', 'text': 'Viral hepatitis panel (HBsAg, Anti-HCV)', 'day': 1, 'category': 'Hepatology-Specific', 'required': true},
        {'id': 'g-b6', 'text': 'Ascitic fluid analysis (if ascites)', 'day': 1, 'category': 'Hepatology-Specific', 'required': false},
      ],
      'radiology': [
        {'id': 'g-r1', 'text': 'USG Abdomen with portal Doppler', 'day': 1, 'required': true},
        {'id': 'g-r2', 'text': 'CXR', 'day': 1, 'required': true},
      ],
      'treatment_orders': [
        {'id': 'g-t1', 'text': 'IV fluids + blood transfusion PRN', 'required': true},
        {'id': 'g-t2', 'text': 'IV PPI (Pantoprazole 80mg bolus then 8mg/hr)', 'required': true},
        {'id': 'g-t3', 'text': 'Lactulose 30ml TDS (if encephalopathy)', 'required': false},
      ],
      'referrals': [
        {'id': 'g-ref1', 'text': 'Gastroenterology — OGD / variceal banding', 'required': true},
      ],
      'scheme_packages': [],
      'discharge_criteria': [
        {'id': 'g-dc1', 'text': 'OGD done (variceal screening/banding if indicated)', 'hard_block': true},
        {'id': 'g-dc2', 'text': 'SBP ruled out or treated', 'hard_block': true},
        {'id': 'g-dc3', 'text': 'Alcohol cessation counseling documented', 'hard_block': false},
      ],
    },
    updatedAt: DateTime(2026, 1, 1),
  );

  // ── DETAILED: CKD ────────────────────────────────────────────────
  static final _ckd = SyndromeProtocol(
    id: 'syn-08', code: 'SYN-08-CKD',
    name: 'Chronic Kidney Disease',
    category: 'Nephrology', version: 1, isActive: true,
    baseTemplate: {
      'history': [
        {'id': 'c-h1', 'text': 'Duration of CKD, baseline creatinine/eGFR', 'required': true},
        {'id': 'c-h2', 'text': 'Etiology (DM, HTN, GN, ADPKD)', 'required': true},
        {'id': 'c-h3', 'text': 'Dialysis status (type, frequency, access)', 'required': true},
        {'id': 'c-h4', 'text': 'Medications (EPO, binders, calcitriol)', 'required': true},
      ],
      'examination': [
        {'id': 'c-e1', 'text': 'Volume status (JVP, edema, lung creps)', 'required': true},
        {'id': 'c-e2', 'text': 'Dialysis access examination (fistula thrill/bruit)', 'required': true},
        {'id': 'c-e3', 'text': 'BP lying and standing', 'required': true},
      ],
      'blood_investigations': [
        {'id': 'c-b1', 'text': 'CBC', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'c-b2', 'text': 'RFT (Cr, BUN, Na, K, Ca, PO4)', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'c-b3', 'text': 'ABG', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'c-b4', 'text': 'iPTH, 25-OH Vitamin D', 'day': 2, 'category': 'CKD-Specific', 'required': true},
        {'id': 'c-b5', 'text': 'Iron studies (Ferritin, TSAT)', 'day': 2, 'category': 'CKD-Specific', 'required': true},
        {'id': 'c-b6', 'text': 'HBsAg, Anti-HCV, HIV (pre-dialysis)', 'day': 1, 'category': 'Serology', 'required': true},
      ],
      'radiology': [
        {'id': 'c-r1', 'text': 'USG KUB (size, echogenicity, obstruction)', 'day': 1, 'required': true},
        {'id': 'c-r2', 'text': 'CXR', 'day': 1, 'required': true},
      ],
      'treatment_orders': [
        {'id': 'c-t1', 'text': 'BP target <130/80: Telmisartan 40-80mg', 'required': true},
        {'id': 'c-t2', 'text': 'Inj Erythropoietin 4000 IU SC weekly (if Hb <10)', 'required': false},
        {'id': 'c-t3', 'text': 'Tab Calcium Carbonate 500mg TDS (phosphate binder)', 'required': false},
      ],
      'referrals': [
        {'id': 'c-ref1', 'text': 'Nephrology — dialysis plan, transplant evaluation', 'required': true},
        {'id': 'c-ref2', 'text': 'Vascular Surgery — AV fistula creation', 'required': true},
      ],
      'scheme_packages': [],
      'discharge_criteria': [
        {'id': 'c-dc1', 'text': 'Permanent vascular access placed OR surgery date confirmed', 'hard_block': true},
        {'id': 'c-dc2', 'text': 'Dialysis center slot confirmed', 'hard_block': true},
        {'id': 'c-dc3', 'text': 'Renal diet counseling documented', 'hard_block': false},
      ],
    },
    updatedAt: DateTime(2026, 1, 1),
  );

  // ── DETAILED: Hematology ─────────────────────────────────────────
  static final _hematology = SyndromeProtocol(
    id: 'syn-12', code: 'SYN-12-HEMATOLOGY',
    name: 'Hematological Disorders',
    category: 'Hematology', version: 1, isActive: true,
    baseTemplate: {
      'history': [
        {'id': 'he-h1', 'text': 'Duration & severity of anemia symptoms', 'required': true},
        {'id': 'he-h2', 'text': 'Bleeding history', 'required': true},
        {'id': 'he-h3', 'text': 'Dietary history (vegetarian, pica)', 'required': false},
      ],
      'examination': [
        {'id': 'he-e1', 'text': 'Pallor, jaundice, petechiae', 'required': true},
        {'id': 'he-e2', 'text': 'Hepatosplenomegaly, lymphadenopathy', 'required': true},
      ],
      'blood_investigations': [
        {'id': 'he-b1', 'text': 'CBC with indices (MCV, MCH, RDW)', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'he-b2', 'text': 'Peripheral blood smear', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'he-b3', 'text': 'Reticulocyte count', 'day': 1, 'category': 'Baseline', 'required': true},
        {'id': 'he-b4', 'text': 'Iron studies (serum iron, TIBC, ferritin)', 'day': 1, 'category': 'Anemia Workup', 'required': true},
        {'id': 'he-b5', 'text': 'Vitamin B12, Folate levels', 'day': 1, 'category': 'Anemia Workup', 'required': true},
        {'id': 'he-b6', 'text': 'LDH, haptoglobin, Coombs test (if hemolysis)', 'day': 2, 'category': 'Hemolysis Screen', 'required': false},
      ],
      'radiology': [
        {'id': 'he-r1', 'text': 'CXR', 'day': 1, 'required': false},
      ],
      'treatment_orders': [
        {'id': 'he-t1', 'text': 'Iron replacement (IV/oral) as per deficiency', 'required': true},
        {'id': 'he-t2', 'text': 'Blood transfusion if Hb <7 or symptomatic', 'required': false},
      ],
      'referrals': [
        {'id': 'he-ref1', 'text': 'Hematology (if atypical smear, suspected malignancy)', 'required': false},
      ],
      'scheme_packages': [],
      'discharge_criteria': [
        {'id': 'he-dc1', 'text': 'Peripheral smear reviewed by hematologist', 'hard_block': true},
        {'id': 'he-dc2', 'text': 'B12/folate/iron levels available, replacement started', 'hard_block': true},
        {'id': 'he-dc3', 'text': 'Hematology follow-up scheduled', 'hard_block': false},
      ],
    },
    updatedAt: DateTime(2026, 1, 1),
  );

  // ── STUBS: Remaining 15 syndromes ────────────────────────────────
  static SyndromeProtocol _stub(String id, String code, String name, String category) =>
    SyndromeProtocol(
      id: id, code: code, name: name, category: category,
      version: 1, isActive: true,
      baseTemplate: {
        'history': [{'id': '$id-h1', 'text': 'Complete history per protocol', 'required': true}],
        'examination': [{'id': '$id-e1', 'text': 'Focused examination per protocol', 'required': true}],
        'blood_investigations': [{'id': '$id-b1', 'text': 'Baseline bloods (CBC, RFT, LFT)', 'day': 1, 'category': 'Baseline', 'required': true}],
        'radiology': [{'id': '$id-r1', 'text': 'CXR', 'day': 1, 'required': true}],
        'treatment_orders': [{'id': '$id-t1', 'text': 'Per protocol treatment', 'required': true}],
        'referrals': [],
        'scheme_packages': [],
        'discharge_criteria': [{'id': '$id-dc1', 'text': 'Clinically stable for discharge', 'hard_block': true}],
      },
      updatedAt: DateTime(2026, 1, 1),
    );

  static final _acs = _stub('syn-03', 'SYN-03-ACS', 'Acute Coronary Syndrome / Chest Pain', 'Cardiovascular');
  static final _hf = _stub('syn-04', 'SYN-04-HF', 'Heart Failure', 'Cardiovascular');
  static final _htnEmergency = _stub('syn-05', 'SYN-05-HTN-EMERGENCY', 'Hypertensive Emergency', 'Cardiovascular');
  static final _aki = _stub('syn-07', 'SYN-07-AKI', 'Acute Kidney Injury', 'Nephrology');
  static final _electrolyte = _stub('syn-09', 'SYN-09-ELECTROLYTE', 'Electrolyte & Acid-Base Disorders', 'Electrolyte / Metabolic');
  static final _neuro = _stub('syn-10', 'SYN-10-NEURO', 'Neurological Syndromes', 'Neurology');
  static final _endocrine = _stub('syn-11', 'SYN-11-ENDOCRINE', 'Endocrine & Metabolic Emergencies', 'Endocrinology');
  static final _rheumatology = _stub('syn-13', 'SYN-13-RHEUMATOLOGY', 'Rheumatological / Autoimmune', 'Rheumatology');
  static final _poisoning = _stub('syn-14', 'SYN-14-POISONING', 'Poisoning & Toxicology', 'Toxicology');
  static final _shock = _stub('syn-15', 'SYN-15-SHOCK', 'Shock & Multiorgan Dysfunction', 'Critical Care');
  static final _nutrition = _stub('syn-16', 'SYN-16-NUTRITION', 'Nutritional Deficiencies', 'Nutrition');
  static final _oncology = _stub('syn-17', 'SYN-17-ONCOLOGY', 'Oncology / Heme-Malignancy', 'Oncology');
  static final _psych = _stub('syn-18', 'SYN-18-PSYCH', 'Psychiatric Presentations in Medicine', 'Psychiatry');
  static final _derm = _stub('syn-19', 'SYN-19-DERM', 'Dermatologic Manifestations of Systemic Disease', 'Dermatology');
  static final _icu = _stub('syn-20', 'SYN-20-ICU', 'Critical Care / ICU Syndromes', 'Critical Care');
}
