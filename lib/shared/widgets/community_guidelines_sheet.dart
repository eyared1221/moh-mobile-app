import 'package:flutter/material.dart';

class CommunityGuidelinesSheet extends StatelessWidget {
  const CommunityGuidelinesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          Text('• Be respectful and supportive'),
          Text('• No harmful or offensive language'),
          Text('• Do not share personal information'),
          Text('• Health-related topics only'),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
