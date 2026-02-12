import 'package:flutter/material.dart';

class TimelineViewScreen extends StatelessWidget {
  final String admissionId;
  const TimelineViewScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5-Day Timeline')),
      body: Center(child: Text('Timeline for admission: $admissionId\nGantt view — to be implemented')),
    );
  }
}
