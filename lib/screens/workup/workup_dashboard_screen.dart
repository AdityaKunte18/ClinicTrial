import 'package:flutter/material.dart';

class WorkupDashboardScreen extends StatelessWidget {
  final String admissionId;
  const WorkupDashboardScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workup Dashboard')),
      body: Center(child: Text('Workup for admission: $admissionId\n6 tabs — to be implemented')),
    );
  }
}
