import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/notification_badge.dart';
import '../../../notifications/data/app_notification_service.dart';
import '../../../notifications/data/notification_provider.dart';
import '../../../notifications/presentation/pages/notification_center_page.dart';
import '../../data/learning_service.dart';
import '../../domain/entities/learning_module_entity.dart';
import '../../domain/usecases/get_learning_modules_use_case.dart';
import '../controllers/learning_modules_controller.dart';
import '../widgets/learning_module_card.dart';
import 'learning_module_detail_page.dart';

class LearningModulesPage extends StatefulWidget {
  final String age;
  final String? userName;

  const LearningModulesPage({
    super.key,
    required this.age,
    this.userName,
  });

  @override
  State<LearningModulesPage> createState() => _LearningModulesPageState();
}

class _LearningModulesPageState extends State<LearningModulesPage> {
  late final LearningModulesController _controller;
  late final PageController _pageController;
  int _currentIndex = 0;
  List<LearningModuleEntity> _learningModules = [];
  bool _isLoading = true;
  String? _errorMessage;
  final AppNotificationService _notificationService = AppNotificationService.instance;
  final NotificationProvider _provider = NotificationProvider();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = LearningModulesController(
      GetLearningModulesUseCase(LearningService.instance),
    );
    _pageController = PageController(viewportFraction: 0.96);
    _loadLearningModules();
    _unreadCount = _provider.unreadCount;
    _loadUnreadCount();
    _provider.addListener(_onNotificationCountChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Future<void> _loadLearningModules() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final modules = await _controller.loadModules();
      
      setState(() {
        _learningModules = modules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load learning modules. Please try again.';
        _isLoading = false;
      });
    }
  }

  
  void _goNext() {
    if (_currentIndex < _learningModules.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Learning Modules'),
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: AppBottomNav(
          age: widget.age,
          currentIndex: 1,
          userName: widget.userName,
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Learning Modules'),
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadLearningModules,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          age: widget.age,
          currentIndex: 1,
          userName: widget.userName,
        ),
      );
    }

    if (_learningModules.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Learning Modules'),
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No learning modules available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          age: widget.age,
          currentIndex: 1,
          userName: widget.userName,
        ),
      );
    }

    final currentModule = _learningModules[_currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Learning Modules'),
        actions: [
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _learningModules.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final module = _learningModules[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: LearningModuleCard(
                      module: module,
                      moduleNumber: index + 1,
                      onMoreTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearningModuleDetailPage(module: module),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: Row(
                children: [
                  _NavCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: _currentIndex == 0 ? null : _goPrevious,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _learningModules.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _NavCircleButton(
                    icon: Icons.arrow_forward_ios,
                    onTap: _currentIndex == _learningModules.length - 1
                        ? null
                        : _goNext,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${_currentIndex + 1} / ${_learningModules.length}  •  ${currentModule.title}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        age: widget.age,
        currentIndex: 1,
        userName: widget.userName,
      ),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDisabled ? colorScheme.surfaceVariant : colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDisabled ? colorScheme.onSurfaceVariant : colorScheme.onPrimary,
          size: 18,
        ),
      ),
    );
  }
}
