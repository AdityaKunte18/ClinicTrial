import 'package:flutter/material.dart';

class AdmissionWizardScreen extends StatelessWidget {
  const AdmissionWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Admission')),
      body: const Center(child: Text('Admission wizard (5 steps) — to be implemented')),
    );
  }
}
