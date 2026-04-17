import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/hero_banner.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/notification_badge.dart';
import '../../../notifications/data/app_notification_service.dart';
import '../../../notifications/data/notification_provider.dart';
import '../../../notifications/presentation/pages/notification_center_page.dart';
import '../../../learning/presentation/pages/learning_module_page.dart';
import '../../../mentor/presentation/pages/mentor_page.dart';
import '../../../risk_assessment/presentation/pages/risk_assessment_page.dart';
import '../../../services/presentation/pages/clinic_page.dart';

class HomePage extends StatefulWidget {
  final String age;
  final String? userName;

  const HomePage({super.key, required this.age, this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _pressedNavIndex;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;
  final AppNotificationService _notificationService = AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _unreadCount = _provider.unreadCount;
    _loadUnreadCount();
    _provider.addListener(_onNotificationCountChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
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

  void _handleScroll() {
    final hasScrolled = _scrollController.offset > 12;
    if (hasScrolled == _hasScrolled) {
      return;
    }

    setState(() {
      _hasScrolled = hasScrolled;
    });
  }

  Future<void> _loadUnreadCount() async {
    await _notificationService.getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 760;
    final navCards = _buildNavCards();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _hasScrolled
            ? colorScheme.surfaceVariant.withOpacity(isDark ? 0.18 : 0.9)
            : Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Health Support'),
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
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildSlantedHero(isDark, colorScheme, isCompactHeight),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, isCompactHeight ? 20 : 28),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isCompactHeight ? 0.92 : 0.96,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildNavCard(
                    navCards[index],
                    isDark,
                    index,
                    colorScheme,
                  );
                }, childCount: navCards.length),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 0,
        userName: widget.userName,
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
    );
  }

  Widget _buildSlantedHero(
    bool isDark,
    ColorScheme colorScheme,
    bool isCompactHeight,
  ) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-0.06)
          ..rotateY(0.03),
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isCompactHeight ? 2 : 4,
          ),
          constraints: BoxConstraints(minHeight: isCompactHeight ? 78 : 95),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.onSurface.withOpacity(0.12),
                      colorScheme.onSurface.withOpacity(0.01),
                    ]
                  : [colorScheme.surface, colorScheme.surfaceVariant],
            ),
            border: Border.all(
              color: isDark ? colorScheme.outlineVariant : colorScheme.surface,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: HeroBanner(
                title: "Choose Your Health Support",
                subtitle: "",
                age: widget.age,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_HomeNavCardData> _buildNavCards() {
    return [
      _HomeNavCardData(
        title: 'Risk Assessment',
        image: 'assets/images/assesment.png',
        icon: Icons.fact_check_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RiskAssessmentPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Learning Module',
        image: 'assets/images/modules.png',
        icon: Icons.menu_book_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LearningModulesPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Get Health Service',
        image: 'assets/images/clinic.png',
        icon: Icons.local_hospital_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ClinicPage(age: widget.age, userName: widget.userName),
            ),
          );
        },
      ),
      _HomeNavCardData(
        title: 'Get Peer Mentor',
        image: 'assets/images/getmentor.png',
        icon: Icons.people_alt_outlined,
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorPage(
                age: widget.age,
                userName: widget.userName,
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildNavCard(
    _HomeNavCardData data,
    bool isDark,
    int index,
    ColorScheme colorScheme,
  ) {
    final isPressed = _pressedNavIndex == index;
    final isCompactHeight = MediaQuery.sizeOf(context).height < 760;
    const outerRadius = 22.0;

    return GestureDetector(
      onTap: () => data.onTap(context),
      onTapDown: (_) => setState(() => _pressedNavIndex = index),
      onTapUp: (_) => setState(() => _pressedNavIndex = null),
      onTapCancel: () => setState(() => _pressedNavIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(color: colorScheme.outlineVariant),
          color: isDark ? colorScheme.surface : Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    data.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: Icon(
                          data.icon,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: isCompactHeight ? 42 : 46,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Text(
                      data.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: isCompactHeight ? 14 : 15,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeNavCardData {
  final String title;
  final String image;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  const _HomeNavCardData({
    required this.title,
    required this.image,
    required this.icon,
    required this.onTap,
  });
}
