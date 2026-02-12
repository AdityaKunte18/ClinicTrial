import 'package:flutter/material.dart';

class RemindersInboxScreen extends StatelessWidget {
  const RemindersInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: const Center(child: Text('Active reminders by patient — to be implemented')),
    );
  }
}
