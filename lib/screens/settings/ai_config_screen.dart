import 'package:flutter/material.dart';

class AiConfigScreen extends StatelessWidget {
  const AiConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Configuration')),
      body: const Center(child: Text('API key, feature toggles, usage — to be implemented')),
    );
  }
}
