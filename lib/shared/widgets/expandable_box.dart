import 'package:flutter/material.dart';

class ExpandableBox extends StatefulWidget {
  final String title;
  final Widget content;

  const ExpandableBox({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ExpandableBox> createState() => _ExpandableBoxState();
}

class _ExpandableBoxState extends State<ExpandableBox> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => open = !open),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
            if (open)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: widget.content,
              ),
          ],
        ),
      ),
    );
  }
}
