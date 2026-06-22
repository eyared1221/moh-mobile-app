import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/responsive/responsive_spacing.dart';
import '../../../../core/responsive/responsive_text.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/global_notification_bell.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = LearningModulesController(
      GetLearningModulesUseCase(LearningService.instance),
    );
    _pageController = PageController(viewportFraction: 0.96);
    _bootstrapLearningModules();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapLearningModules() async {
    final cachedModules = await _controller.loadCachedModules();
    if (!mounted) return;

    if (cachedModules.isNotEmpty) {
      setState(() {
        _learningModules = cachedModules;
        _currentIndex = 0;
        _isLoading = false;
        _errorMessage = null;
      });
    }

    unawaited(
      _refreshLearningModules(showLoading: cachedModules.isEmpty),
    );
  }

  Future<void> _refreshLearningModules({bool showLoading = false}) async {
    try {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final modules = await _controller.loadModules();
      if (!mounted) return;

      final nextIndex = modules.isEmpty
          ? 0
          : _currentIndex.clamp(0, modules.length - 1) as int;

      setState(() {
        _learningModules = modules;
        _currentIndex = nextIndex;
        _errorMessage = null;
        _isLoading = false;
      });

      if (_pageController.hasClients && modules.isNotEmpty) {
        _pageController.jumpToPage(nextIndex);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_learningModules.isEmpty) {
          _errorMessage = 'Failed to load learning modules. Please try again.';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _syncLearningModules() async {
    await _refreshLearningModules(
      showLoading: _learningModules.isEmpty,
    );
  }

  Future<void> _retryLoadingModules() async {
    await _refreshLearningModules(showLoading: true);
    if (_pageController.hasClients && _learningModules.isNotEmpty) {
      final nextIndex = _currentIndex.clamp(0, _learningModules.length - 1) as int;
      _pageController.jumpToPage(nextIndex);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _learningModules.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Learning Modules'),
          actions: [
            GlobalTopBarActions(onSyncPressed: _syncLearningModules),
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
            GlobalTopBarActions(onSyncPressed: _syncLearningModules),
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
                  onPressed: _retryLoadingModules,
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
            GlobalTopBarActions(onSyncPressed: _syncLearningModules),
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
          GlobalTopBarActions(onSyncPressed: _syncLearningModules),
        ],
      ),
      body: ResponsiveContainer.safe(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSpacing.xsSpacing(context),
                      vertical: ResponsiveSpacing.xsSpacing(context),
                    ),
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
              padding: EdgeInsets.fromLTRB(
                ResponsiveSpacing.mdSpacing(context),
                ResponsiveSpacing.xsSpacing(context),
                ResponsiveSpacing.mdSpacing(context),
                ResponsiveSpacing.smSpacing(context),
              ),
              child: Row(
                children: [
                  _NavCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: _currentIndex == 0 ? null : _goPrevious,
                  ),
                  SizedBox(width: ResponsiveSpacing.smSpacing(context)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _learningModules.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: EdgeInsets.symmetric(horizontal: ResponsiveSpacing.xsSpacing(context)),
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
                  SizedBox(width: ResponsiveSpacing.smSpacing(context)),
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
              padding: EdgeInsets.only(bottom: ResponsiveSpacing.xsSpacing(context)),
              child: Text(
                '${_currentIndex + 1} / ${_learningModules.length}  •  ${currentModule.title}',
                textAlign: TextAlign.center,
                style: ResponsiveText.bodyStyle(
                  context,
                  color: colorScheme.onSurfaceVariant,
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
