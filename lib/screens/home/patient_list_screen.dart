import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/reminders')),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/settings/profile')),
        ],
      ),
      body: const Center(child: Text('Patient list — to be implemented')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admission'),
        icon: const Icon(Icons.add),
        label: const Text('Admit'),
      ),
    );
  }
}
