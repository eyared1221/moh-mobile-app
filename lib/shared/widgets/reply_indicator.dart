import 'package:flutter/material.dart';

class ReplyIndicator extends StatelessWidget {
  final String replyingTo;
  final VoidCallback onCancel;

  const ReplyIndicator({
    super.key,
    required this.replyingTo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.reply, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to: $replyingTo',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
