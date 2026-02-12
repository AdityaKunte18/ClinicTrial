import 'package:flutter/material.dart';

class HandoffNoteScreen extends StatelessWidget {
  final String admissionId;
  const HandoffNoteScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handoff Note')),
      body: Center(child: Text('Handoff for: $admissionId\nSummary + pending items — to be implemented')),
    );
  }
}
