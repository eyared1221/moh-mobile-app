import 'package:flutter/material.dart';

import '../../data/profile_repository.dart';
import '../../models/profile_user.dart';

class LanguagePage extends StatelessWidget {
  final ProfileUser profile;

  const LanguagePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('App Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'English',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.check_circle, color: colorScheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'More languages will be added soon.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final updated = profile.copyWith(language: 'English');
          await ProfileRepository().saveProfile(updated);
          if (!context.mounted) return;
          Navigator.pop(context, updated);
        },
        icon: const Icon(Icons.save_alt_rounded),
        label: const Text('Save'),
      ),
    );
  }
}
