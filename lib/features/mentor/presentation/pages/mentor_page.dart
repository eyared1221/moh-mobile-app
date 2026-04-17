import 'package:flutter/material.dart';

import '../../data/mentor_repository.dart';
import '../../models/mentor.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/notification_badge.dart';
import '../../../notifications/data/app_notification_service.dart';
import '../../../notifications/data/notification_provider.dart';
import '../../../notifications/presentation/pages/notification_center_page.dart';
import '../widgets/mentor_card.dart';

class MentorPage extends StatefulWidget {
  final String? age;
  final String? userName;

  const MentorPage({
    super.key,
    this.age,
    this.userName,
  });

  @override
  State<MentorPage> createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final MentorRepository _repository = MentorRepository();
  late final TextEditingController _searchController;
  late final Future<List<Mentor>> _mentorsFuture;
  String _query = '';
  final AppNotificationService _notificationService = AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mentorsFuture = _repository.fetchMentors();
    _unreadCount = _provider.unreadCount;
    _loadUnreadCount();
    _provider.addListener(_onNotificationCountChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _provider.removeListener(_onNotificationCountChanged);
    super.dispose();
  }

  void _onNotificationCountChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = _provider.unreadCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Peer Mentors'),
        actions: [
          NotificationBadge(
            count: _unreadCount,
            child: IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Notifications',
            ),
          ),
        ],
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
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 2,
        userName: widget.userName,
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

  Future<void> _loadUnreadCount() async {
    await _notificationService.getUnreadCount();
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
    );
  }
}
