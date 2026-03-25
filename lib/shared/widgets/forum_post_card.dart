import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import 'package:flutter/services.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final String currentUserId;
  final ForumPost? repliedPost;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const ForumPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    this.repliedPost,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
    required this.onReport,
  });

  bool get isMine => post.userId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(post.avatar),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  post.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'copy') {
                      await Clipboard.setData(ClipboardData(text: post.message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      onCopy();
                    }
                    if (value == 'delete') onDelete();
                    if (value == 'report') onReport();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'copy', child: Text('Copy')),
                    if (isMine)
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    if (!isMine)
                      const PopupMenuItem(value: 'report', child: Text('Report')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Reply section
            if (repliedPost != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(repliedPost!.avatar),
                      radius: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${repliedPost!.displayName}: ${repliedPost!.message}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message
            Text(
              post.message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 6),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
