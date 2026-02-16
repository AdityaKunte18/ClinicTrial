import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admission_wizard_provider.dart';
import '../../providers/patient_providers.dart';
import '../../providers/syndrome_providers.dart';
import 'widgets/syndrome_selector.dart';

class AdmissionWizardScreen extends ConsumerStatefulWidget {
  const AdmissionWizardScreen({super.key});

  @override
  ConsumerState<AdmissionWizardScreen> createState() =>
      _AdmissionWizardScreenState();
}

class _AdmissionWizardScreenState
    extends ConsumerState<AdmissionWizardScreen> {
  final _bedCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset wizard when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(admissionWizardProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _bedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(admissionWizardProvider);
    final theme = Theme.of(context);

    // Navigate away after successful creation
    ref.listen<AdmissionWizardState>(admissionWizardProvider, (prev, next) {
      if (next.createdAdmissionId != null &&
          prev?.createdAdmissionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient admitted successfully!')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Admission'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        currentStep: wizard.currentStep,
        onStepContinue: () {
          final notifier = ref.read(admissionWizardProvider.notifier);
          if (wizard.currentStep == 0 && wizard.canProceedFromPatient) {
            notifier.setStep(1);
          } else if (wizard.currentStep == 1 &&
              wizard.canProceedFromSyndromes) {
            notifier.setStep(2);
          } else if (wizard.currentStep == 2) {
            notifier.submit();
          }
        },
        onStepCancel: () {
          if (wizard.currentStep > 0) {
            ref
                .read(admissionWizardProvider.notifier)
                .setStep(wizard.currentStep - 1);
          } else {
            context.pop();
          }
        },
        onStepTapped: (step) {
          // Only allow going back
          if (step < wizard.currentStep) {
            ref.read(admissionWizardProvider.notifier).setStep(step);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = wizard.currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: wizard.isSubmitting
                      ? null
                      : details.onStepContinue,
                  child: wizard.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isLast ? 'Confirm & Admit' : 'Continue'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(
                      wizard.currentStep == 0 ? 'Cancel' : 'Back'),
                ),
              ],
            ),
          );
        },
        steps: [
          // ── Step 1: Select Patient ────────────────────
          Step(
            title: const Text('Patient'),
            subtitle: wizard.selectedPatient != null
                ? Text(wizard.selectedPatient!.name)
                : null,
            isActive: wizard.currentStep >= 0,
            state: wizard.currentStep > 0
                ? StepState.complete
                : StepState.indexed,
            content: _buildPatientStep(wizard, theme),
          ),

          // ── Step 2: Select Syndromes ──────────────────
          Step(
            title: const Text('Syndromes'),
            subtitle: wizard.selectedSyndromeIds.isNotEmpty
                ? Text('${wizard.selectedSyndromeIds.length} selected')
                : null,
            isActive: wizard.currentStep >= 1,
            state: wizard.currentStep > 1
                ? StepState.complete
                : StepState.indexed,
            content: SizedBox(
              height: 400,
              child: SyndromeSelector(
                selectedIds: wizard.selectedSyndromeIds,
                primaryId: wizard.primarySyndromeId,
                onToggle: (id) => ref
                    .read(admissionWizardProvider.notifier)
                    .toggleSyndrome(id),
                onSetPrimary: (id) => ref
                    .read(admissionWizardProvider.notifier)
                    .setPrimarySyndrome(id),
              ),
            ),
          ),

          // ── Step 3: Confirm ───────────────────────────
          Step(
            title: const Text('Confirm'),
            isActive: wizard.currentStep >= 2,
            state: wizard.createdAdmissionId != null
                ? StepState.complete
                : StepState.indexed,
            content: _buildConfirmStep(wizard, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientStep(AdmissionWizardState wizard, ThemeData theme) {
    final patientsAsync = ref.watch(patientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient picker
        Text('Select a patient:', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        patientsAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (patients) {
            return Column(
              children: patients.map((p) {
                final isSelected = wizard.selectedPatient?.id == p.id;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                      '${p.uhid} · ${p.age}${p.sex}'),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : null,
                  dense: true,
                  onTap: () => ref
                      .read(admissionWizardProvider.notifier)
                      .selectPatient(p),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 16),

        // Bed number
        TextField(
          controller: _bedCtrl,
          decoration: const InputDecoration(
            labelText: 'Bed Number',
            hintText: 'e.g. M1-12',
            prefixIcon: Icon(Icons.bed_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) =>
              ref.read(admissionWizardProvider.notifier).setBedNumber(v),
        ),

        if (!wizard.canProceedFromPatient &&
            wizard.currentStep == 0) ...[
          const SizedBox(height: 8),
          Text(
            'Select a patient and enter bed number to continue',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmStep(AdmissionWizardState wizard, ThemeData theme) {
    final synProtocols = ref.watch(syndromeProtocolsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient summary
        _summaryRow(theme, 'Patient', wizard.selectedPatient?.name ?? '—'),
        _summaryRow(
            theme, 'UHID', wizard.selectedPatient?.uhid ?? '—'),
        _summaryRow(theme, 'Bed', wizard.bedNumber),

        const Divider(height: 24),

        // Syndromes summary
        Text('Syndromes:', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        synProtocols.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (protocols) {
            final protocolMap = {for (final p in protocols) p.id: p};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wizard.selectedSyndromeIds.map((id) {
                final p = protocolMap[id];
                final isPrimary = id == wizard.primarySyndromeId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        isPrimary ? Icons.star : Icons.circle,
                        size: isPrimary ? 18 : 8,
                        color: isPrimary
                            ? Colors.amber
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(p?.name ?? id),
                      if (isPrimary)
                        Text(' (Primary)',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.amber.shade800)),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        if (wizard.error != null) ...[
          const SizedBox(height: 12),
          Text(wizard.error!,
              style: TextStyle(color: theme.colorScheme.error)),
        ],

        const SizedBox(height: 12),
        Text(
          'Workup items will be automatically generated from the selected syndrome templates.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
