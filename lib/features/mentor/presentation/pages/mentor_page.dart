import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/global_notification_bell.dart';
import '../../data/mentor_repository.dart';
import '../../domain/entities/mentor_entity.dart';
import '../../domain/usecases/get_mentors_use_case.dart';
import '../controllers/mentor_page_controller.dart';
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
  late final MentorPageController _controller;
  late final TextEditingController _searchController;
  List<MentorEntity> _mentors = const <MentorEntity>[];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = MentorPageController(
      GetMentorsUseCase(MentorRepository()),
    );
    _searchController = TextEditingController();
    _bootstrapMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapMentors() async {
    final cachedMentors = await _controller.loadCachedMentors();
    if (!mounted) return;

    if (cachedMentors.isNotEmpty) {
      setState(() {
        _mentors = cachedMentors;
        _isLoading = false;
        _errorMessage = null;
      });
    }

    unawaited(
      _refreshMentors(showLoading: cachedMentors.isEmpty),
    );
  }

  Future<void> _refreshMentors({bool showLoading = false}) async {
    try {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final mentors = await _controller.loadMentors();
      if (!mounted) return;

      setState(() {
        _mentors = mentors;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_mentors.isEmpty) {
          _errorMessage = 'Failed to load mentors. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _syncMentors() async {
    await _refreshMentors(showLoading: _mentors.isEmpty);
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
          GlobalTopBarActions(onSyncPressed: _syncMentors),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: _buildBody(colorScheme, textTheme),
      ),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 2,
        userName: widget.userName,
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading && _mentors.isEmpty) {
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

    if (_errorMessage != null && _mentors.isEmpty) {
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
            _errorMessage!,
            'Please try again.',
          ),
        ],
      );
    }

    if (_mentors.isEmpty) {
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

    final filtered = _controller.filterMentors(_mentors, _query);
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

}
