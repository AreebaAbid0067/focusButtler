import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:productivity_app/models/achievement.dart';
import 'package:provider/provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FocusProvider>();

    return Scaffold(
      backgroundColor: HyperfocusColors.background,
      appBar: AppBar(
        title: const Text("Achievements"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(provider),
            const SizedBox(height: 32),

            _buildSectionHeader("Recent Unlocks"),
            const SizedBox(height: 16),

            ..._buildUnlockedAchievements(provider),

            const SizedBox(height: 32),

            _buildSectionHeader("All Achievements"),
            const SizedBox(height: 16),

            ..._buildAllAchievements(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HyperfocusColors.purposeful.withValues(alpha: 0.3),
            HyperfocusColors.necessary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HyperfocusColors.purposeful.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: HyperfocusColors.purposeful, size: 32),
              const SizedBox(width: 12),
              Text(
                "${provider.unlockedAchievementCount}/${provider.achievements.length}",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HyperfocusColors.purposeful,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Achievements Unlocked",
            style: TextStyle(
              color: HyperfocusColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: HyperfocusColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                height: 12,
                width: MediaQuery.of(context).size.width * 0.7 * provider.achievementProgress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [HyperfocusColors.purposeful, Color(0xFF00E676)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ).animate().fadeIn().slideX(begin: -0.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HyperfocusColors.purposeful,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  List<Widget> _buildUnlockedAchievements(FocusProvider provider) {
    final unlocked = provider.achievements
        .where((a) => a.isUnlocked)
        .toList()
      ..sort((a, b) => (b.unlockedAt ?? DateTime.now())
          .compareTo(a.unlockedAt ?? DateTime.now()));

    if (unlocked.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: HyperfocusColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.lock_open, color: HyperfocusColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                "Complete focus sessions to unlock achievements!",
                style: TextStyle(
                  color: HyperfocusColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return unlocked.take(4).map((achievement) {
      return _buildAchievementCard(achievement, context, isHighlighted: true)
          .animate()
          .fadeIn()
          .slideX(begin: 0.1);
    }).toList();
  }

  List<Widget> _buildAllAchievements(FocusProvider provider) {
    final categories = AchievementCategory.values;

    return categories.map((category) {
      final categoryAchievements = provider.achievements
          .where((a) => a.category == category)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category),
          const SizedBox(height: 12),
          ...categoryAchievements.map(
            (achievement) => _buildAchievementCard(achievement, context),
          ),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryHeader(AchievementCategory category) {
    final (icon, title) = switch (category) {
      AchievementCategory.streaks => ('local_fire_department', 'Streaks'),
      AchievementCategory.focus => ('timer', 'Focus Time'),
      AchievementCategory.tasks => ('task_alt', 'Tasks'),
      AchievementCategory.milestones => ('military_tech', 'Milestones'),
    };

    return Row(
      children: [
        Icon(
          IconData(int.parse(icon.replaceAll('icons.', '')), fontFamily: 'MaterialIcons'),
          color: HyperfocusColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: HyperfocusColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    BuildContext context, {
    bool isHighlighted = false,
  }) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? isHighlighted
                ? HyperfocusColors.purposeful.withValues(alpha: 0.15)
                : HyperfocusColors.surface
            : HyperfocusColors.surfaceHighlight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? HyperfocusColors.purposeful.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        boxShadow: isUnlocked && isHighlighted
            ? [
                BoxShadow(
                  color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? HyperfocusColors.purposeful.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: HyperfocusColors.purposeful.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              _getAchievementIcon(achievement.icon),
              color: isUnlocked ? HyperfocusColors.purposeful : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : HyperfocusColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: HyperfocusColors.purposeful,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: HyperfocusColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: 100 * achievement.progress,
                        decoration: BoxDecoration(
                          color: HyperfocusColors.purposeful,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${achievement.currentValue}/${achievement.targetValue}",
                    style: TextStyle(
                      color: HyperfocusColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
