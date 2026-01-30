import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/screens/focus_screen.dart';
import 'package:productivity_app/screens/capture_screen.dart';
import 'package:productivity_app/screens/review_screen.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/screens/settings_screen.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:productivity_app/models/achievement.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FocusScreen(),
    const CaptureScreen(),
    const ReviewScreen(),
  ];

  final List<String> _motivationalQuotes = [
    "What is your most important task right now?",
    "Attention is your most limited resource.",
    "Single-tasking is productivity superpowers.",
    "Control your attention, control your life.",
    "What would you accomplish if you entered hyperfocus?",
    "Small steps compound into massive results.",
    "Your attention is worth protecting.",
  ];

  List<String> _pendingAchievements = [];
  AnimationController? _achievementController;

  @override
  void initState() {
    super.initState();
    _achievementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _achievementController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getRandomQuote() {
    return _motivationalQuotes[_selectedIndex % _motivationalQuotes.length];
  }

  void _checkForNewAchievements(BuildContext context, FocusProvider provider) {
    if (_pendingAchievements.isEmpty && provider.newlyUnlockedAchievements.isNotEmpty) {
      _pendingAchievements = List.from(provider.newlyUnlockedAchievements);
      _showAchievementUnlockedDialog(context, provider);
    }
  }

  void _showAchievementUnlockedDialog(BuildContext context, FocusProvider provider) {
    if (_pendingAchievements.isEmpty) return;

    final achievementId = _pendingAchievements.removeAt(0);
    final achievement = provider.achievements.firstWhere((a) => a.id == achievementId);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AchievementUnlockedDialog(
          achievement: achievement,
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            // Check if there are more pending achievements
            if (_pendingAchievements.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _showAchievementUnlockedDialog(context, provider);
                }
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FocusProvider>();

    // Check for new achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewAchievements(context, provider);
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/hyperfocus-logo.svg',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              "Hyperfocus",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          if (provider.currentStreak > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: HyperfocusColors.purposeful, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${provider.currentStreak}",
                    style: const TextStyle(
                      color: HyperfocusColors.purposeful,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (provider.unlockedAchievementCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HyperfocusColors.necessary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: HyperfocusColors.necessary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${provider.unlockedAchievementCount}",
                    style: const TextStyle(
                      color: HyperfocusColors.necessary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 32),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.center_focus_strong_outlined),
            selectedIcon: Icon(Icons.center_focus_strong),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Capture',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Review',
          ),
        ],
      ),
    );
  }
}

class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HyperfocusColors.surface,
                HyperfocusColors.surface.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: HyperfocusColors.purposeful.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: HyperfocusColors.purposeful.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration particles
              ...List.generate(12, (index) {
                final angle = (index * 30) * 3.14159 / 180;
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            HyperfocusColors.purposeful.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Achievement icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: HyperfocusColors.purposeful.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _getAchievementIcon(achievement.icon),
                  color: HyperfocusColors.purposeful,
                  size: 50,
                ),
              )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .glow(duration: 1000.ms, iterations: 3),

              const SizedBox(height: 24),

              // "Achievement Unlocked" text
              Text(
                "ACHIEVEMENT UNLOCKED",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: HyperfocusColors.purposeful,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),

              const SizedBox(height: 12),

              // Achievement title
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2),

              const SizedBox(height: 8),

              // Achievement description
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HyperfocusColors.textSecondary,
                    ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HyperfocusColors.purposeful,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'military_tech':
        return Icons.military_tech;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'schedule':
        return Icons.schedule;
      case 'timelapse':
        return Icons.timelapse;
      case 'stars':
        return Icons.stars;
      case 'task_alt':
        return Icons.task_alt;
      case 'verified':
        return Icons.verified;
      case 'diamond':
        return Icons.diamond;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'crown':
        return Icons.crown;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }
}
