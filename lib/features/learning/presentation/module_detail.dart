// lib/screens/module_detail.dart
import 'package:flutter/material.dart';

class ModuleDetail extends StatelessWidget {
  const ModuleDetail({super.key});

  @override
  Widget build(BuildContext context) {
    // expect arguments: Map<String, String> with title, subtitle, image
    final args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, String>? item = args is Map<String, String> ? args : null;

    final title = item?['title'] ?? 'Module';
    final image = item?['image'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF005C8F)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (image.isNotEmpty) Image.asset(image, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Module details and content go here. Replace with your real content.'),
          ],
        ),
      ),
    );
  }
}
