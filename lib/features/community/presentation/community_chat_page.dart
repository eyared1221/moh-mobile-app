import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/forum_post.dart';
import '../../../shared/widgets/forum_input_box.dart';
import '../../../shared/widgets/forum_guidelines.dart';
import '../../../shared/widgets/top_header.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class CommunityChatPage extends StatefulWidget {
  final String ageRange;
  const CommunityChatPage({super.key, required this.ageRange});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final _uuid = const Uuid();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  final List<ForumPost> _globalPosts = [];
  final Map<String, String?> _postReactions = {};
  
  // Telegram-style Emoji List
  final List<String> allEmojis = [
    '👍', '👎', '❤️', '🔥', '😂', '😮', '😢', '👏', 
    '💯', '✨', '🚀', '🤔', '🙏', '🎉', '🎈', '🍕', 
    '⭐', '🌈', '✅', '📍', '🌸', '💎', '💡', '🔔', 
    '🎁', '📱', '💻', '🎮', '🏀', '🌍', '⚡', '😇',
    '😍', '🤩', '😜', '🤫', '🤨', '😬', '😴', '🤯'
  ];

  String currentUserId = 'local-user';
  String currentUserName = 'Anonymous'; 
  String currentAvatarAsset = 'assets/avatars/avatar1.png';

  final List<String> avatarOptions = [
    'assets/avatars/avatar1.png', 'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png', 'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png', 'assets/avatars/avatar6.png',
  ];

  String? _editingPostId;
  String? _replyingToId;
  OverlayEntry? _overlayEntry;
  
  // Expansion state for the reaction menu
  bool _isEmojiExpanded = false;

  void _closeMenu() { 
    _overlayEntry?.remove(); 
    _overlayEntry = null; 
    _isEmojiExpanded = false; // Reset expansion state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      resizeToAvoidBottomInset: true, 
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(child: TopHeader(showBack: true)),
      ),
      bottomNavigationBar: AppBottomNav(ageRange: widget.ageRange, currentIndex: 0),
      body: Column(
        children: [
          const ForumGuidelines(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10), 
              itemCount: _globalPosts.length,
              itemBuilder: (context, index) => _buildChatBubble(_globalPosts[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
Widget _buildChatBubble(ForumPost post) {
  bool isMine = post.userId == currentUserId;
  String? reaction = _postReactions[post.id];
  String timeStr = DateFormat('hh:mm a').format(post.timestamp);

  return Align(
    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTapDown: (d) => _showMenu(context, post, d.globalPosition, isMine),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 300,
            minWidth: 120,
          ),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isMine ? 15 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 15),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
            ],
          ),
          child: Stack(
            children: [
              // 1. MESSAGE TEXT
              Padding(
                // Bottom padding increased to 32 to give footer plenty of room
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 32), 
                child: Text(
                  post.message,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              // 2. FOOTER ROW (Emoji + Time/Status)
              Positioned(
                left: 10,
                right: 8,
                bottom: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Forces space between emoji and time
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Emoji on the left
                    reaction != null 
                      ? Text(reaction, style: const TextStyle(fontSize: 15)) 
                      : const SizedBox.shrink(), // Empty space if no reaction
                    
                    // Time and Seen on the right
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10, 
                            color: isMine ? Colors.green[800]?.withOpacity(0.6) : Colors.grey[600]
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          Icon(
                            post.isSeen ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 15,
                            color: post.isSeen ? const Color(0xFF34B7F1) : Colors.grey[400],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
 
  void _showMenu(BuildContext context, ForumPost post, Offset tapPos, bool isMine) {
    _closeMenu();
    _overlayEntry = OverlayEntry(builder: (context) => StatefulBuilder(
      builder: (context, setMenuState) {
        return Stack(children: [
          GestureDetector(onTap: _closeMenu, behavior: HitTestBehavior.opaque, child: Container(color: Colors.transparent)),
          Positioned(
            left: isMine ? null : 40, 
            right: isMine ? 40 : null, 
            top: tapPos.dy > 400 ? tapPos.dy - (_isEmojiExpanded ? 320 : 200) : tapPos.dy, 
            child: _buildPopMenu(post, setMenuState),
          ),
        ]);
      }
    ));
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildPopMenu(ForumPost post, StateSetter setMenuState) {
    return Material(
      elevation: 20,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: _isEmojiExpanded ? 260 : 220,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isEmojiExpanded)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...allEmojis.take(4).map((e) => _buildEmojiBtn(post, e)),
                  GestureDetector(
                    onTap: () {
                      setMenuState(() => _isEmojiExpanded = true);
                      setState(() => _isEmojiExpanded = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.blue),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Reactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          setMenuState(() => _isEmojiExpanded = false);
                          setState(() => _isEmojiExpanded = false);
                        },
                        child: const Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, mainAxisSpacing: 5, crossAxisSpacing: 5,
                      ),
                      itemCount: allEmojis.length,
                      itemBuilder: (context, i) => _buildEmojiBtn(post, allEmojis[i]),
                    ),
                  ),
                ],
              ),
            const Divider(height: 24),
            _buildMenuItem(Icons.reply_rounded, "Reply", () { setState(() => _replyingToId = post.id); _closeMenu(); }),
            _buildMenuItem(Icons.content_copy_rounded, "Copy", () { Clipboard.setData(ClipboardData(text: post.message)); _closeMenu(); }),
            if (post.userId == currentUserId) ...[
              _buildMenuItem(Icons.edit_rounded, "Edit", () { setState(() { _editingPostId = post.id; _messageController.text = post.message; }); _closeMenu(); }),
              _buildMenuItem(Icons.delete_outline_rounded, "Delete", () { setState(() => _globalPosts.removeWhere((p) => p.id == post.id)); _closeMenu(); }),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiBtn(ForumPost post, String emoji) {
    return InkWell(
      onTap: () {
        setState(() => _postReactions[post.id] = (_postReactions[post.id] == emoji) ? null : emoji);
        _closeMenu();
      },
      borderRadius: BorderRadius.circular(10),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF333333), size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyQuote(String id) {
    final original = _globalPosts.firstWhere((p) => p.id == id, orElse: () => ForumPost(id: '', userId: '', displayName: '', avatar: '', message: 'Deleted', timestamp: DateTime.now()));
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Colors.blue, width: 4))
      ),
      child: Text(original.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
    );
  }

  Widget _buildInputArea() {
    return ForumInputBox(
      controller: _messageController,
      selectedAvatar: currentAvatarAsset,
      avatarOptions: avatarOptions,
      userName: currentUserName,
      modeLabel: _editingPostId != null ? "Editing Mode" : (_replyingToId != null ? "Replying Mode" : null),
      onAvatarChanged: (a) => setState(() => currentAvatarAsset = a),
      onNameChanged: (n) => setState(() => currentUserName = n),
      onCancelMode: () => setState(() { _editingPostId = null; _replyingToId = null; _messageController.clear(); }),
      onSend: (msg) {
        if (msg.trim().isEmpty) return;
        setState(() {
          if (_editingPostId != null) {
            int idx = _globalPosts.indexWhere((p) => p.id == _editingPostId);
            if (idx != -1) _globalPosts[idx].message = msg;
            _editingPostId = null;
          } else {
            _globalPosts.add(ForumPost(id: _uuid.v4(), userId: currentUserId, displayName: currentUserName, avatar: currentAvatarAsset, message: msg, timestamp: DateTime.now(), replyTo: _replyingToId));
            _replyingToId = null;
          }
          _messageController.clear();
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        });
      },
    );
  }
}