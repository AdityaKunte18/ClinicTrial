import 'package:flutter/material.dart';

class DischargeCheckpointScreen extends StatelessWidget {
  final String admissionId;
  const DischargeCheckpointScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discharge Checkpoint')),
      body: Center(child: Text('Discharge gate for: $admissionId\nHard-blocks & soft-warnings — to be implemented')),
    );
  }
}
