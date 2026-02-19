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
      'result_options': [
        // Malarial antigen (f-b3)
        {'id': 'ro-fev-mp-pf', 'template_item_id': 'f-b3', 'label': 'Positive (P. falciparum)', 'value': 'pf_positive', 'sort': 1},
        {'id': 'ro-fev-mp-pv', 'template_item_id': 'f-b3', 'label': 'Positive (P. vivax)', 'value': 'pv_positive', 'sort': 2},
        {'id': 'ro-fev-mp-mixed', 'template_item_id': 'f-b3', 'label': 'Positive (Mixed)', 'value': 'mixed_positive', 'sort': 3},
        {'id': 'ro-fev-mp-neg', 'template_item_id': 'f-b3', 'label': 'Negative', 'value': 'mp_negative', 'sort': 4},
        // Dengue NS1 + IgM/IgG (f-b4)
        {'id': 'ro-fev-den-ns1', 'template_item_id': 'f-b4', 'label': 'NS1 Positive', 'value': 'ns1_positive', 'sort': 1},
        {'id': 'ro-fev-den-igm', 'template_item_id': 'f-b4', 'label': 'IgM Positive', 'value': 'igm_positive', 'sort': 2},
        {'id': 'ro-fev-den-igg', 'template_item_id': 'f-b4', 'label': 'IgG Positive', 'value': 'igg_positive', 'sort': 3},
        {'id': 'ro-fev-den-neg', 'template_item_id': 'f-b4', 'label': 'All Negative', 'value': 'dengue_negative', 'sort': 4},
        // Blood culture (f-b5)
        {'id': 'ro-fev-bc-gp', 'template_item_id': 'f-b5', 'label': 'Growth (Gram-positive)', 'value': 'growth_gram_positive', 'sort': 1},
        {'id': 'ro-fev-bc-gn', 'template_item_id': 'f-b5', 'label': 'Growth (Gram-negative)', 'value': 'growth_gram_negative', 'sort': 2},
        {'id': 'ro-fev-bc-ng', 'template_item_id': 'f-b5', 'label': 'No growth at 48h', 'value': 'no_growth', 'sort': 3},
        // Widal test (f-b6)
        {'id': 'ro-fev-wid-sig', 'template_item_id': 'f-b6', 'label': 'Significant titer (>=1:160)', 'value': 'widal_significant', 'sort': 1},
        {'id': 'ro-fev-wid-ns', 'template_item_id': 'f-b6', 'label': 'Non-significant titer', 'value': 'widal_nonsignificant', 'sort': 2},
        // Scrub typhus IgM (f-b7)
        {'id': 'ro-fev-st-pos', 'template_item_id': 'f-b7', 'label': 'Positive', 'value': 'scrub_positive', 'sort': 1},
        {'id': 'ro-fev-st-neg', 'template_item_id': 'f-b7', 'label': 'Negative', 'value': 'scrub_negative', 'sort': 2},
      ],
      'classifications': [
        {
          'id': 'cls-fev-malaria-pf',
          'name': 'Malaria (P. falciparum)',
          'code': 'FEV-MALARIA-PF',
          'priority': 20,
          'criteria': [{'template_item_id': 'f-b3', 'operator': 'equals', 'value': 'pf_positive'}],
          'guidelines': [{'name': 'WHO Malaria Treatment Guidelines 2022', 'section': 'Severe & Uncomplicated Pf Malaria'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-fev-pf-b1', 'text': 'G6PD assay', 'day': 1, 'required': true},
              {'id': 'cls-fev-pf-b2', 'text': 'Reticulocyte count', 'day': 2, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-fev-pf-t1', 'text': 'Inj Artesunate IV per WHO protocol', 'required': true, 'hard_block': true},
            ],
          },
        },
        {
          'id': 'cls-fev-malaria-pv',
          'name': 'Malaria (P. vivax)',
          'code': 'FEV-MALARIA-PV',
          'priority': 15,
          'criteria': [{'template_item_id': 'f-b3', 'operator': 'equals', 'value': 'pv_positive'}],
          'guidelines': [{'name': 'WHO Malaria Treatment Guidelines 2022', 'section': 'P. vivax Treatment'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-fev-pv-b1', 'text': 'G6PD assay (before primaquine)', 'day': 1, 'required': true, 'hard_block': true},
            ],
            'treatment_orders': [
              {'id': 'cls-fev-pv-t1', 'text': 'Tab Chloroquine 25mg/kg over 3 days', 'required': true},
              {'id': 'cls-fev-pv-t2', 'text': 'Tab Primaquine 0.25mg/kg x 14 days (if G6PD normal)', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-fev-dengue',
          'name': 'Dengue Fever',
          'code': 'FEV-DENGUE',
          'priority': 18,
          'criteria': [{'template_item_id': 'f-b4', 'operator': 'equals', 'value': 'ns1_positive'}],
          'guidelines': [{'name': 'WHO Dengue Guidelines 2009', 'section': 'Clinical Management'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-fev-den-b1', 'text': 'Serial platelet count (12-hourly)', 'day': 1, 'required': true},
              {'id': 'cls-fev-den-b2', 'text': 'Hematocrit (serial, for plasma leak)', 'day': 1, 'required': true},
              {'id': 'cls-fev-den-b3', 'text': 'NS1 repeat Day 3', 'day': 3, 'required': false},
            ],
            'treatment_orders': [
              {'id': 'cls-fev-den-t1', 'text': 'Dengue precautions: avoid NSAIDs, IM injections, strict I/O', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-fev-enteric',
          'name': 'Enteric Fever (Typhoid)',
          'code': 'FEV-ENTERIC',
          'priority': 12,
          'criteria': [{'template_item_id': 'f-b6', 'operator': 'equals', 'value': 'widal_significant'}],
          'guidelines': [{'name': 'IAP Guidelines Enteric Fever', 'section': 'Diagnosis & Treatment'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-fev-ent-b1', 'text': 'Blood culture repeat (if initial negative)', 'day': 3, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-fev-ent-t1', 'text': 'Inj Ceftriaxone 2g IV OD or Ciprofloxacin per sensitivity', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-fev-scrub',
          'name': 'Scrub Typhus',
          'code': 'FEV-SCRUB-TYPHUS',
          'priority': 16,
          'criteria': [{'template_item_id': 'f-b7', 'operator': 'equals', 'value': 'scrub_positive'}],
          'guidelines': [{'name': 'ICMR Guidelines Scrub Typhus', 'section': 'Diagnosis & Treatment'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-fev-scr-b1', 'text': 'Weil-Felix test', 'day': 2, 'required': false},
              {'id': 'cls-fev-scr-b2', 'text': 'LFT repeat (Day 3)', 'day': 3, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-fev-scr-t1', 'text': 'Tab Doxycycline 100mg BD x 7 days', 'required': true},
            ],
          },
        },
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
      'result_options': [
        // ABG (r-b2)
        {'id': 'ro-resp-abg-t1', 'template_item_id': 'r-b2', 'label': 'Type 1 Respiratory Failure (hypoxic)', 'value': 'type1_rf', 'sort': 1},
        {'id': 'ro-resp-abg-t2', 'template_item_id': 'r-b2', 'label': 'Type 2 Respiratory Failure (hypercapnic)', 'value': 'type2_rf', 'sort': 2},
        {'id': 'ro-resp-abg-normal', 'template_item_id': 'r-b2', 'label': 'Normal ABG', 'value': 'abg_normal', 'sort': 3},
        // Sputum AFB + CBNAAT (r-b3)
        {'id': 'ro-resp-afb-pos', 'template_item_id': 'r-b3', 'label': 'AFB Positive', 'value': 'afb_positive', 'sort': 1},
        {'id': 'ro-resp-cbn-sens', 'template_item_id': 'r-b3', 'label': 'CBNAAT MTB detected (Rif Sensitive)', 'value': 'mtb_rif_sensitive', 'sort': 2},
        {'id': 'ro-resp-cbn-res', 'template_item_id': 'r-b3', 'label': 'CBNAAT MTB detected (Rif Resistant)', 'value': 'mtb_rif_resistant', 'sort': 3},
        {'id': 'ro-resp-afb-neg', 'template_item_id': 'r-b3', 'label': 'Negative', 'value': 'afb_negative', 'sort': 4},
        // Blood culture (r-b4)
        {'id': 'ro-resp-bc-cap', 'template_item_id': 'r-b4', 'label': 'Growth (typical CAP pathogen)', 'value': 'growth_cap', 'sort': 1},
        {'id': 'ro-resp-bc-atyp', 'template_item_id': 'r-b4', 'label': 'Growth (atypical/resistant)', 'value': 'growth_atypical', 'sort': 2},
        {'id': 'ro-resp-bc-ng', 'template_item_id': 'r-b4', 'label': 'No growth', 'value': 'no_growth', 'sort': 3},
        // Procalcitonin (r-b5)
        {'id': 'ro-resp-pct-high', 'template_item_id': 'r-b5', 'label': 'High (>0.5 — bacterial likely)', 'value': 'pct_high', 'sort': 1},
        {'id': 'ro-resp-pct-low', 'template_item_id': 'r-b5', 'label': 'Low (<0.25 — viral likely)', 'value': 'pct_low', 'sort': 2},
        {'id': 'ro-resp-pct-int', 'template_item_id': 'r-b5', 'label': 'Intermediate (0.25-0.5)', 'value': 'pct_intermediate', 'sort': 3},
      ],
      'classifications': [
        {
          'id': 'cls-resp-tb-sens',
          'name': 'Pulmonary TB (Rif Sensitive)',
          'code': 'RESP-TB-SENS',
          'priority': 20,
          'criteria': [{'template_item_id': 'r-b3', 'operator': 'equals', 'value': 'mtb_rif_sensitive'}],
          'guidelines': [{'name': 'RNTCP/NTEP Guidelines 2021', 'section': 'New Pulmonary TB — Cat I'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-resp-tbs-b1', 'text': 'Sputum repeat (Month 2 follow-up)', 'day': 5, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-resp-tbs-t1', 'text': 'DOTS registration + 4-drug ATT (HRZE)', 'required': true, 'hard_block': true},
              {'id': 'cls-resp-tbs-t2', 'text': 'Contact screening referral', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-resp-tb-resist',
          'name': 'Pulmonary TB (Rif Resistant)',
          'code': 'RESP-TB-MDR',
          'priority': 25,
          'criteria': [{'template_item_id': 'r-b3', 'operator': 'equals', 'value': 'mtb_rif_resistant'}],
          'guidelines': [{'name': 'WHO MDR-TB Guidelines 2022', 'section': 'Shorter MDR Regimen'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-resp-tbr-b1', 'text': 'Culture & DST (full panel)', 'day': 1, 'required': true, 'hard_block': true},
            ],
            'referrals': [
              {'id': 'cls-resp-tbr-ref1', 'text': 'DRTB Center referral — MDR-TB regimen initiation', 'required': true, 'hard_block': true},
            ],
          },
        },
        {
          'id': 'cls-resp-bact-pna',
          'name': 'Bacterial Pneumonia',
          'code': 'RESP-BACT-PNA',
          'priority': 15,
          'criteria': [{'template_item_id': 'r-b4', 'operator': 'equals', 'value': 'growth_cap'}],
          'guidelines': [{'name': 'ATS/IDSA CAP Guidelines 2019', 'section': 'Inpatient Management'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-resp-pna-b1', 'text': 'Procalcitonin repeat Day 3', 'day': 3, 'required': true},
            ],
            'radiology': [
              {'id': 'cls-resp-pna-r1', 'text': 'Repeat CXR Day 5 (resolution check)', 'day': 5, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-resp-pna-t1', 'text': 'Targeted antibiotics per culture sensitivity', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-resp-type2-rf',
          'name': 'Type 2 Respiratory Failure',
          'code': 'RESP-TYPE2-RF',
          'priority': 22,
          'criteria': [{'template_item_id': 'r-b2', 'operator': 'equals', 'value': 'type2_rf'}],
          'guidelines': [{'name': 'BTS Guidelines NIV 2016', 'section': 'Acute Hypercapnic RF'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-resp-t2-b1', 'text': 'Serial ABG (6-hourly on NIV)', 'day': 1, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-resp-t2-t1', 'text': 'NIV/BiPAP setup — target pH >7.35, PaCO2 reduction', 'required': true, 'hard_block': true},
            ],
            'referrals': [
              {'id': 'cls-resp-t2-ref1', 'text': 'Pulmonology consult (urgent)', 'required': true},
            ],
          },
        },
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
      'result_options': [
        // SAAG result options for ascitic fluid analysis (g-b6)
        {'id': 'ro-gi-saag-high', 'template_item_id': 'g-b6', 'label': 'High SAAG (>=1.1) — Portal Hypertension', 'value': 'high_saag', 'sort': 1},
        {'id': 'ro-gi-saag-low', 'template_item_id': 'g-b6', 'label': 'Low SAAG (<1.1) — Non-portal (TB/Malignancy)', 'value': 'low_saag', 'sort': 2},
        {'id': 'ro-gi-saag-sbp', 'template_item_id': 'g-b6', 'label': 'Neutrophil count >250 — SBP', 'value': 'sbp', 'sort': 3},
        // Hepatitis panel options (g-b5)
        {'id': 'ro-gi-hep-hbsag', 'template_item_id': 'g-b5', 'label': 'HBsAg Positive', 'value': 'hbsag_positive', 'sort': 1},
        {'id': 'ro-gi-hep-hcv', 'template_item_id': 'g-b5', 'label': 'Anti-HCV Positive', 'value': 'anti_hcv_positive', 'sort': 2},
        {'id': 'ro-gi-hep-both-neg', 'template_item_id': 'g-b5', 'label': 'Both Negative (Non-B Non-C)', 'value': 'both_negative', 'sort': 3},
        {'id': 'ro-gi-hep-both-pos', 'template_item_id': 'g-b5', 'label': 'Both Positive (HBV + HCV)', 'value': 'both_positive', 'sort': 4},
      ],
      'classifications': [
        {
          'id': 'cls-gi-portal-htn',
          'name': 'Portal Hypertension (High SAAG)',
          'code': 'GI-PORTAL-HTN',
          'priority': 10,
          'criteria': [{'template_item_id': 'g-b6', 'operator': 'equals', 'value': 'high_saag'}],
          'guidelines': [{'name': 'AASLD Practice Guidance 2023', 'section': 'Portal Hypertension Management'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-gi-pht-b1', 'text': 'AFP (hepatocellular carcinoma screening)', 'day': 2, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-gi-pht-ref1', 'text': 'Gastroenterology — UGI endoscopy + EVL if varices', 'required': true, 'hard_block': true},
            ],
            'treatment_orders': [
              {'id': 'cls-gi-pht-t1', 'text': 'Tab Propranolol 20mg BD (variceal prophylaxis)', 'required': true},
              {'id': 'cls-gi-pht-t2', 'text': 'Salt restriction <2g/day + Spironolactone', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-gi-low-saag',
          'name': 'Non-Portal Ascites (Low SAAG)',
          'code': 'GI-LOW-SAAG',
          'priority': 10,
          'criteria': [{'template_item_id': 'g-b6', 'operator': 'equals', 'value': 'low_saag'}],
          'guidelines': [{'name': 'AASLD Practice Guidance 2023', 'section': 'Ascites Differential'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-gi-ls-b1', 'text': 'Ascitic fluid ADA level', 'day': 2, 'required': true},
              {'id': 'cls-gi-ls-b2', 'text': 'Ascitic fluid cytology', 'day': 2, 'required': true},
            ],
            'radiology': [
              {'id': 'cls-gi-ls-r1', 'text': 'CECT Abdomen (rule out malignancy/TB)', 'day': 3, 'required': true, 'hard_block': true},
            ],
          },
        },
        {
          'id': 'cls-gi-sbp',
          'name': 'Spontaneous Bacterial Peritonitis (SBP)',
          'code': 'GI-SBP',
          'priority': 20,
          'criteria': [{'template_item_id': 'g-b6', 'operator': 'equals', 'value': 'sbp'}],
          'guidelines': [{'name': 'EASL CPG 2018', 'section': 'SBP Diagnosis & Treatment'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-gi-sbp-b1', 'text': 'Ascitic fluid culture & sensitivity', 'day': 1, 'required': true, 'hard_block': true},
              {'id': 'cls-gi-sbp-b2', 'text': 'Repeat ascitic fluid after 48h antibiotics', 'day': 3, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-gi-sbp-t1', 'text': 'Inj Ceftriaxone 2g IV OD x 5 days', 'required': true},
              {'id': 'cls-gi-sbp-t2', 'text': 'IV Albumin 1.5g/kg Day 1 + 1g/kg Day 3', 'required': true, 'hard_block': true},
            ],
          },
        },
        {
          'id': 'cls-gi-hbv',
          'name': 'Hepatitis B Related CLD',
          'code': 'GI-HBV-CLD',
          'priority': 15,
          'criteria': [{'template_item_id': 'g-b5', 'operator': 'equals', 'value': 'hbsag_positive'}],
          'guidelines': [{'name': 'AASLD HBV Guidance 2018', 'section': 'Treatment Indications'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-gi-hbv-b1', 'text': 'HBV DNA quantitative', 'day': 2, 'required': true, 'hard_block': true},
              {'id': 'cls-gi-hbv-b2', 'text': 'HBeAg / Anti-HBe', 'day': 2, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-gi-hbv-ref1', 'text': 'Hepatology — antiviral initiation (Tenofovir/Entecavir)', 'required': true},
            ],
          },
        },
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
      'result_options': [
        // GFR staging options for RFT result (c-b2)
        {'id': 'ro-ckd-gfr-g1', 'template_item_id': 'c-b2', 'label': 'GFR >=90 (G1 — Normal)', 'value': 'G1', 'sort': 1},
        {'id': 'ro-ckd-gfr-g2', 'template_item_id': 'c-b2', 'label': 'GFR 60-89 (G2 — Mild decrease)', 'value': 'G2', 'sort': 2},
        {'id': 'ro-ckd-gfr-g3a', 'template_item_id': 'c-b2', 'label': 'GFR 45-59 (G3a — Mild-Moderate)', 'value': 'G3a', 'sort': 3},
        {'id': 'ro-ckd-gfr-g3b', 'template_item_id': 'c-b2', 'label': 'GFR 30-44 (G3b — Moderate-Severe)', 'value': 'G3b', 'sort': 4},
        {'id': 'ro-ckd-gfr-g4', 'template_item_id': 'c-b2', 'label': 'GFR 15-29 (G4 — Severe)', 'value': 'G4', 'sort': 5},
        {'id': 'ro-ckd-gfr-g5', 'template_item_id': 'c-b2', 'label': 'GFR <15 (G5 — Kidney Failure)', 'value': 'G5', 'sort': 6},
        // ABG interpretation (c-b3)
        {'id': 'ro-ckd-abg-normal', 'template_item_id': 'c-b3', 'label': 'Normal ABG', 'value': 'normal', 'sort': 1},
        {'id': 'ro-ckd-abg-met-acid', 'template_item_id': 'c-b3', 'label': 'Metabolic Acidosis', 'value': 'metabolic_acidosis', 'sort': 2},
        {'id': 'ro-ckd-abg-met-alk', 'template_item_id': 'c-b3', 'label': 'Metabolic Alkalosis', 'value': 'metabolic_alkalosis', 'sort': 3},
        // Hepatitis serology (c-b6)
        {'id': 'ro-ckd-hep-neg', 'template_item_id': 'c-b6', 'label': 'All Negative', 'value': 'all_negative', 'sort': 1},
        {'id': 'ro-ckd-hep-hbsag', 'template_item_id': 'c-b6', 'label': 'HBsAg Positive', 'value': 'hbsag_positive', 'sort': 2},
        {'id': 'ro-ckd-hep-hcv', 'template_item_id': 'c-b6', 'label': 'Anti-HCV Positive', 'value': 'anti_hcv_positive', 'sort': 3},
        {'id': 'ro-ckd-hep-hiv', 'template_item_id': 'c-b6', 'label': 'HIV Positive', 'value': 'hiv_positive', 'sort': 4},
      ],
      'classifications': [
        {
          'id': 'cls-ckd-g3a',
          'name': 'CKD Stage 3a (Mild-Moderate)',
          'code': 'CKD-G3a',
          'priority': 5,
          'criteria': [{'template_item_id': 'c-b2', 'operator': 'equals', 'value': 'G3a'}],
          'guidelines': [{'name': 'KDIGO 2024', 'section': 'Chapter 1 — CKD Staging'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-ckd-g3a-b1', 'text': 'UPCR (spot urine)', 'day': 2, 'required': true},
            ],
          },
        },
        {
          'id': 'cls-ckd-g3b',
          'name': 'CKD Stage 3b (Moderate-Severe)',
          'code': 'CKD-G3b',
          'priority': 8,
          'criteria': [{'template_item_id': 'c-b2', 'operator': 'equals', 'value': 'G3b'}],
          'guidelines': [{'name': 'KDIGO 2024', 'section': 'Chapter 1 — CKD Staging'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-ckd-g3b-b1', 'text': 'UPCR (spot urine)', 'day': 2, 'required': true},
              {'id': 'cls-ckd-g3b-b2', 'text': 'iPTH level', 'day': 2, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-ckd-g3b-ref1', 'text': 'Nephrology consultation', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-ckd-g4',
          'name': 'CKD Stage 4 (Severe)',
          'code': 'CKD-G4',
          'priority': 10,
          'criteria': [{'template_item_id': 'c-b2', 'operator': 'equals', 'value': 'G4'}],
          'guidelines': [{'name': 'KDIGO 2024', 'section': 'Chapter 1, Table 3 — Risk Stratification'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-ckd-g4-b1', 'text': 'iPTH level (if not already done)', 'day': 2, 'required': true},
              {'id': 'cls-ckd-g4-b2', 'text': 'Vitamin D (25-OH)', 'day': 2, 'required': true},
              {'id': 'cls-ckd-g4-b3', 'text': 'UPCR (spot urine)', 'day': 2, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-ckd-g4-ref1', 'text': 'Nephrology — mandatory for G4+ (RRT planning)', 'required': true, 'hard_block': true},
            ],
            'treatment_orders': [
              {'id': 'cls-ckd-g4-t1', 'text': 'Restrict protein to 0.8 g/kg/day', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-ckd-g5',
          'name': 'CKD Stage 5 (Kidney Failure)',
          'code': 'CKD-G5',
          'priority': 20,
          'criteria': [{'template_item_id': 'c-b2', 'operator': 'equals', 'value': 'G5'}],
          'guidelines': [{'name': 'KDIGO 2024', 'section': 'Chapter 5 — RRT Planning'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-ckd-g5-b1', 'text': 'iPTH level (urgent)', 'day': 1, 'required': true},
              {'id': 'cls-ckd-g5-b2', 'text': 'Hepatitis B & C serology (pre-dialysis workup)', 'day': 1, 'required': true, 'hard_block': true},
            ],
            'referrals': [
              {'id': 'cls-ckd-g5-ref1', 'text': 'Nephrology — urgent RRT planning', 'required': true, 'hard_block': true},
              {'id': 'cls-ckd-g5-ref2', 'text': 'Vascular Surgery — dialysis access creation', 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-ckd-g5-t1', 'text': 'Restrict protein to 0.6-0.8 g/kg/day', 'required': true},
              {'id': 'cls-ckd-g5-t2', 'text': 'Sodium bicarbonate if metabolic acidosis', 'required': false},
            ],
          },
        },
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
      'result_options': [
        // CBC with indices (he-b1)
        {'id': 'ro-hem-cbc-micro', 'template_item_id': 'he-b1', 'label': 'Microcytic Hypochromic', 'value': 'microcytic_hypochromic', 'sort': 1},
        {'id': 'ro-hem-cbc-macro', 'template_item_id': 'he-b1', 'label': 'Macrocytic', 'value': 'macrocytic', 'sort': 2},
        {'id': 'ro-hem-cbc-normo', 'template_item_id': 'he-b1', 'label': 'Normocytic Normochromic', 'value': 'normocytic_normochromic', 'sort': 3},
        {'id': 'ro-hem-cbc-pancy', 'template_item_id': 'he-b1', 'label': 'Pancytopenia', 'value': 'pancytopenia', 'sort': 4},
        // Peripheral blood smear (he-b2)
        {'id': 'ro-hem-pbs-ida', 'template_item_id': 'he-b2', 'label': 'Iron deficiency picture', 'value': 'iron_deficiency_picture', 'sort': 1},
        {'id': 'ro-hem-pbs-mega', 'template_item_id': 'he-b2', 'label': 'Megaloblastic changes', 'value': 'megaloblastic_changes', 'sort': 2},
        {'id': 'ro-hem-pbs-dimorph', 'template_item_id': 'he-b2', 'label': 'Dimorphic', 'value': 'dimorphic', 'sort': 3},
        {'id': 'ro-hem-pbs-abnorm', 'template_item_id': 'he-b2', 'label': 'Abnormal cells (blasts/atypical)', 'value': 'abnormal_cells', 'sort': 4},
        // Iron studies (he-b4)
        {'id': 'ro-hem-iron-def', 'template_item_id': 'he-b4', 'label': 'Iron deficient (low ferritin, high TIBC)', 'value': 'iron_deficient', 'sort': 1},
        {'id': 'ro-hem-iron-over', 'template_item_id': 'he-b4', 'label': 'Iron overload', 'value': 'iron_overload', 'sort': 2},
        {'id': 'ro-hem-iron-normal', 'template_item_id': 'he-b4', 'label': 'Normal iron studies', 'value': 'iron_normal', 'sort': 3},
        // Vitamin B12, Folate (he-b5)
        {'id': 'ro-hem-vit-b12def', 'template_item_id': 'he-b5', 'label': 'B12 deficient', 'value': 'b12_deficient', 'sort': 1},
        {'id': 'ro-hem-vit-foldef', 'template_item_id': 'he-b5', 'label': 'Folate deficient', 'value': 'folate_deficient', 'sort': 2},
        {'id': 'ro-hem-vit-bothdef', 'template_item_id': 'he-b5', 'label': 'Both deficient', 'value': 'both_deficient', 'sort': 3},
        {'id': 'ro-hem-vit-normal', 'template_item_id': 'he-b5', 'label': 'Both normal', 'value': 'both_normal', 'sort': 4},
        // LDH, haptoglobin, Coombs (he-b6)
        {'id': 'ro-hem-hemo-pos', 'template_item_id': 'he-b6', 'label': 'Hemolytic (high LDH, low haptoglobin, Coombs+)', 'value': 'hemolytic_coombs_pos', 'sort': 1},
        {'id': 'ro-hem-hemo-nonhemo', 'template_item_id': 'he-b6', 'label': 'Non-hemolytic', 'value': 'non_hemolytic', 'sort': 2},
        {'id': 'ro-hem-hemo-neg', 'template_item_id': 'he-b6', 'label': 'Coombs negative hemolysis', 'value': 'hemolytic_coombs_neg', 'sort': 3},
      ],
      'classifications': [
        {
          'id': 'cls-hem-ida',
          'name': 'Iron Deficiency Anemia',
          'code': 'HEM-IDA',
          'priority': 10,
          'criteria': [{'template_item_id': 'he-b4', 'operator': 'equals', 'value': 'iron_deficient'}],
          'guidelines': [{'name': 'BSH IDA Guidelines 2021', 'section': 'Investigation & Management'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-hem-ida-b1', 'text': 'Stool for occult blood', 'day': 2, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-hem-ida-ref1', 'text': 'GI evaluation (OGD + Colonoscopy)', 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-hem-ida-t1', 'text': 'Parenteral Iron (IV FCM) if Hb <8 or oral intolerance', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-hem-megalo',
          'name': 'Megaloblastic Anemia',
          'code': 'HEM-MEGALOBLASTIC',
          'priority': 10,
          'criteria': [{'template_item_id': 'he-b5', 'operator': 'equals', 'value': 'b12_deficient'}],
          'guidelines': [{'name': 'BSH B12/Folate Guidelines', 'section': 'Diagnosis & Treatment'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-hem-meg-b1', 'text': 'Homocysteine level', 'day': 2, 'required': true},
              {'id': 'cls-hem-meg-b2', 'text': 'Methylmalonic acid', 'day': 2, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-hem-meg-t1', 'text': 'Inj Vitamin B12 1000mcg IM daily x 7 days, then weekly', 'required': true},
            ],
          },
        },
        {
          'id': 'cls-hem-aiha',
          'name': 'Hemolytic Anemia (Coombs+)',
          'code': 'HEM-AIHA',
          'priority': 20,
          'criteria': [{'template_item_id': 'he-b6', 'operator': 'equals', 'value': 'hemolytic_coombs_pos'}],
          'guidelines': [{'name': 'ASH AIHA Guidelines 2020', 'section': 'Warm AIHA Management'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-hem-aiha-b1', 'text': 'DCT / ICT (direct & indirect Coombs)', 'day': 2, 'required': true},
              {'id': 'cls-hem-aiha-b2', 'text': 'Reticulocyte count (repeat)', 'day': 2, 'required': true},
            ],
            'treatment_orders': [
              {'id': 'cls-hem-aiha-t1', 'text': 'Prednisolone 1mg/kg/day (steroid protocol)', 'required': true},
            ],
            'referrals': [
              {'id': 'cls-hem-aiha-ref1', 'text': 'Hematology — urgent (AIHA workup)', 'required': true, 'hard_block': true},
            ],
          },
        },
        {
          'id': 'cls-hem-pancy',
          'name': 'Pancytopenia',
          'code': 'HEM-PANCYTOPENIA',
          'priority': 25,
          'criteria': [{'template_item_id': 'he-b1', 'operator': 'equals', 'value': 'pancytopenia'}],
          'guidelines': [{'name': 'BSH Pancytopenia Guidelines', 'section': 'Investigation Algorithm'}],
          'additional_workup': {
            'blood_investigations': [
              {'id': 'cls-hem-pan-b1', 'text': 'Bone marrow aspiration + biopsy', 'day': 2, 'required': true, 'hard_block': true},
              {'id': 'cls-hem-pan-b2', 'text': 'Flow cytometry', 'day': 3, 'required': true},
            ],
            'referrals': [
              {'id': 'cls-hem-pan-ref1', 'text': 'Hematology — urgent (pancytopenia evaluation)', 'required': true, 'hard_block': true},
            ],
          },
        },
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
