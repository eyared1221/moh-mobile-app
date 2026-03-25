import 'package:flutter/material.dart';

class ForumGuidelines extends StatelessWidget {
  const ForumGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You may chat anonymously or choose any name and avatar.\n\n"
              "Please be respectful and supportive. This is a safe space for "
              "discussions related to HIV, STDs, GBV, and Hepatitis.",
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
