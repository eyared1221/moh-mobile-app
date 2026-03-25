import 'package:flutter/material.dart';

class ForumInputBox extends StatefulWidget {
  final TextEditingController controller;
  final String selectedAvatar;
  final List<String> avatarOptions;
  final String userName;
  final String? modeLabel;
  final Function(String) onAvatarChanged;
  final Function(String) onNameChanged;
  final VoidCallback onCancelMode;
  final Function(String) onSend;

  const ForumInputBox({
    super.key,
    required this.controller,
    required this.selectedAvatar,
    required this.avatarOptions,
    required this.userName,
    required this.modeLabel,
    required this.onAvatarChanged,
    required this.onNameChanged,
    required this.onCancelMode,
    required this.onSend,
  });

  @override
  State<ForumInputBox> createState() => _ForumInputBoxState();
}

class _ForumInputBoxState extends State<ForumInputBox> {
  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameFocused = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _nameFocusNode.addListener(() {
      if (mounted) setState(() => _isNameFocused = _nameFocusNode.hasFocus);
    });
  }

  // Helper to safely build an avatar (prevents crashes if asset is missing)
  Widget _buildSafeAvatar(String assetPath, {double radius = 24}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: radius, color: Colors.grey[600]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Conditional check for modeLabel
          if (widget.modeLabel != null) _buildModeBar(),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- AVATAR & NAME COLUMN ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
                      ),
                      child: _buildSafeAvatar(widget.selectedAvatar),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      onChanged: widget.onNameChanged,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: _isNameFocused 
                            ? const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2))
                            : InputBorder.none,
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // --- MESSAGE INPUT ---
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: "Message",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // --- SEND BUTTON ---
              // Inside ForumInputBox Row
GestureDetector(
  onTap: () => widget.onSend(widget.controller.text),
  child: Container(
    height: 48,
    width: 48,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      // Using a solid blue or your previous gradient
      color: Colors.blue, 
    ),
    child: const Icon(
      Icons.send_rounded, // The classic "Before" send icon
      color: Colors.white, 
      size: 24
    ),
  ),
),
                ],
          ),
        
        ],
      ),
    );
  }

  Widget _buildModeBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(widget.modeLabel!.contains("Edit") ? Icons.edit : Icons.reply_rounded, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.modeLabel!, style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13))),
          GestureDetector(onTap: widget.onCancelMode, child: Icon(Icons.close, size: 18, color: Colors.blue[700])),
        ],
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Avatar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15),
              itemCount: widget.avatarOptions.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  widget.onAvatarChanged(widget.avatarOptions[i]);
                  Navigator.pop(context);
                },
                child: _buildSafeAvatar(widget.avatarOptions[i], radius: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}