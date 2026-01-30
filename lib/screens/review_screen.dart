import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:productivity_app/models/task.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _isWeeklyView = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FocusProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Review & Plan",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        _buildViewToggle(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Align your attention with your intention.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: HyperfocusColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Weekly Stats Heatmap
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "This Week",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          "${provider.totalSessions} sessions",
                          style: const TextStyle(
                            color: HyperfocusColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyHeatmap(),
                    const SizedBox(height: 12),
                    _buildWeeklyStats(provider),
                  ],
                ),
              ).animate().fadeIn(),
            ),

            // Analytics Summary
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HyperfocusColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(context, "45%", "Purposeful",
                            HyperfocusColors.purposeful),
                        _buildStat(
                            context, "2h 10m", "Deep Work", Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQuadrantProgress(),
                  ],
                ),
              ).animate().fadeIn().slideX(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // AI Insights Section
            if (provider.aiInsights.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology,
                              color: HyperfocusColors.purposeful, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "AI Insights",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: HyperfocusColors.purposeful,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...provider.aiInsights.take(3).map((insight) {
                        return _buildInsightCard(insight, context);
                      }),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Task List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Tasks",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      "${provider.tasks.where((t) => !t.isCompleted).length} remaining",
                      style: const TextStyle(
                        color: HyperfocusColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tasks = provider.tasks;
                    if (index >= tasks.length) return null;
                    final task = tasks[index];
                    return _buildTaskItem(task, context);
                  },
                  childCount: provider.tasks.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HyperfocusColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleChip("Daily", !_isWeeklyView),
          _buildToggleChip("Weekly", _isWeeklyView),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isWeeklyView = !isSelected),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? HyperfocusColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : HyperfocusColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyHeatmap() {
    // Generate last 7 days with mock data
    final List<Map<String, dynamic>> weekData = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      // Mock: more recent days have more activity
      return {
        'date': date,
        'sessions': index >= 4 ? (index - 2) : index,
        'minutes': index >= 4 ? (index - 2) * 25 : index * 15,
      };
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekData.map((day) {
          final intensity = (day['sessions'] / 5).clamp(0.0, 1.0);
          final isToday = day['date'].day == DateTime.now().day;

          return Column(
            children: [
              Text(
                _getDayAbbreviation(day['date']),
                style: TextStyle(
                  color: isToday
                      ? HyperfocusColors.purposeful
                      : HyperfocusColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getHeatmapColor(intensity),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "${day['sessions']}",
                    style: TextStyle(
                      color: intensity > 0.5
                          ? Colors.white
                          : HyperfocusColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  String _getDayAbbreviation(DateTime date) {
    final abbreviations = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return abbreviations[date.weekday % 7];
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity < 0.2)
      return HyperfocusColors.purposeful.withValues(alpha: 0.3);
    if (intensity < 0.5)
      return HyperfocusColors.purposeful.withValues(alpha: 0.6);
    if (intensity < 0.8)
      return HyperfocusColors.purposeful.withValues(alpha: 1.0);
    return HyperfocusColors.purposeful;
  }

  Widget _buildWeeklyStats(FocusProvider provider) {
    final totalMinutes = provider.totalFocusMinutes;
    final sessions = provider.totalSessions;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              "${hours}h ${minutes}m",
              "Total Focus Time",
              Icons.timer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStat(
              "$sessions",
              "Sessions Completed",
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMiniStat(
              "${provider.currentStreak}",
              "Day Streak",
              Icons.local_fire_department,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HyperfocusColors.purposeful.withValues(alpha: 0.2),
              HyperfocusColors.necessary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildInsightCard(AIInsight insight, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getInsightColor(insight.type),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getInsightIcon(insight.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HyperfocusColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.productivity:
        return HyperfocusColors.purposeful;
      case InsightType.energy:
        return HyperfocusColors.necessary;
      case InsightType.attention:
        return HyperfocusColors.distracting;
      case InsightType.tasks:
        return HyperfocusColors.unnecessary;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.productivity:
        return Icons.trending_up;
      case InsightType.energy:
        return Icons.battery_charging_full;
      case InsightType.attention:
        return Icons.psychology;
      case InsightType.tasks:
        return Icons.lightbulb_outline;
    }
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HyperfocusColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: HyperfocusColors.purposeful, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: HyperfocusColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String value, String label, Color color,
      [IconData icon = Icons.analytics]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HyperfocusColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 100.ms).fadeIn();
  }

  Widget _buildTaskItem(Task task, BuildContext context) {
    final color = _getTaskColor(task.type);
    final icon = _getTaskIcon(task.type);

    return Dismissible(
      key: Key(task.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: HyperfocusColors.unnecessary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onDismissed: (direction) {
        context.read<FocusProvider>().deleteTask(task.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HyperfocusColors.surface
              .withValues(alpha: task.isCompleted ? 0.6 : 1.0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.transparent
                : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.isCompleted
                          ? HyperfocusColors.textSecondary
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTaskTypeName(task.type),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                if (task.isCompleted) {
                  context.read<FocusProvider>().uncompleteTask(task.id);
                } else {
                  context.read<FocusProvider>().completeTask(task.id);
                }
              },
              activeColor: color,
              checkColor: Colors.black,
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }

  Color _getTaskColor(TaskType type) {
    switch (type) {
      case TaskType.purposeful:
        return HyperfocusColors.purposeful;
      case TaskType.necessary:
        return HyperfocusColors.necessary;
      case TaskType.distracting:
        return HyperfocusColors.distracting;
      case TaskType.unnecessary:
        return HyperfocusColors.unnecessary;
    }
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.purposeful:
        return Icons.star_outline;
      case TaskType.necessary:
        return Icons.check_circle_outline;
      case TaskType.distracting:
        return Icons.notifications_none;
      case TaskType.unnecessary:
        return Icons.delete_outline;
    }
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.purposeful:
        return "Purposeful";
      case TaskType.necessary:
        return "Necessary";
      case TaskType.distracting:
        return "Distracting";
      case TaskType.unnecessary:
        return "Unnecessary";
    }
  }
}
