import 'package:flutter/material.dart';

class CommunityComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  const CommunityComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask a health question...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: enabled ? onSend : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005C8F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
