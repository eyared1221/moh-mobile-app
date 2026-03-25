class ForumPost {
  final String id;
  final String userId;
  final String displayName;
  final String avatar;
  String message;
  final String? replyTo;
  final DateTime timestamp;
  bool isSeen;

  ForumPost({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.avatar,
    required this.message,
    required this.timestamp,
    this.replyTo,
    this.isSeen = false,
  });
}