import 'package:flutter/material.dart';

import '../../data/mentor_repository.dart';
import '../../models/mentor.dart';
import '../widgets/mentor_card.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({super.key});

  @override
  State<MentorPage> createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final MentorRepository _repository = MentorRepository();
  late final TextEditingController _searchController;
  late final Future<List<Mentor>> _mentorsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mentorsFuture = _repository.fetchMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: colorScheme.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mentor Contact',
          style:
              textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ) ??
              TextStyle(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FutureBuilder<List<Mentor>>(
          future: _mentorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: 2 + 5,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSearchBar(colorScheme, textTheme);
                  }
                  if (index == 1) {
                    return _buildSearchDivider(colorScheme);
                  }
                  return const MentorSkeletonCard();
                },
              );
            }

            final mentors = snapshot.data ?? const <Mentor>[];
            if (mentors.isEmpty) {
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSearchBar(colorScheme, textTheme),
                  const SizedBox(height: 8),
                  _buildSearchDivider(colorScheme),
                  const SizedBox(height: 16),
                  _buildEmptyState(
                    colorScheme,
                    textTheme,
                    'No mentors available right now.',
                    'Please check back later.',
                  ),
                ],
              );
            }

            final filtered = _filterMentors(mentors, _query);
            if (filtered.isEmpty) {
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSearchBar(colorScheme, textTheme),
                  const SizedBox(height: 8),
                  _buildSearchDivider(colorScheme),
                  const SizedBox(height: 16),
                  _buildEmptyState(
                    colorScheme,
                    textTheme,
                    'No mentors match your search.',
                    'Try a different name or number.',
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: 2 + filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSearchBar(colorScheme, textTheme);
                }
                if (index == 1) {
                  return _buildSearchDivider(colorScheme);
                }
                return MentorCard(mentor: filtered[index - 2]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style:
          textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ) ??
          TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Search mentors',
        hintStyle:
            textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ) ??
            TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSearchDivider(ColorScheme colorScheme) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildEmptyState(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_off_rounded,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style:
                textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ) ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style:
                textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  List<Mentor> _filterMentors(List<Mentor> mentors, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return mentors;
    return mentors.where((mentor) {
      final name = mentor.fullName.toLowerCase();
      final phone = mentor.phone.toLowerCase();
      return name.contains(normalized) || phone.contains(normalized);
    }).toList();
  }
}
