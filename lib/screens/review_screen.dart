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
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                        _buildStat(context, "2h 10m", "Deep Work", Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQuadrantProgress(),
                  ],
                ),
              ).animate().fadeIn().slideX(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final provider = context.watch<FocusProvider>();
                    final tasks = provider.tasks;
                    // Mock counts for now, or filter by actual type if we updated the types to match quadrants exactly
                    // For now, mapping: Purposeful -> Purposeful, Necessary -> Necessary, Distracting -> Distracting
                    // We need to define Unnecessary in TaskType or map it.
                    // Let's assume TaskType matches.

                    int purposefulCount = tasks
                        .where((t) =>
                            t.type == TaskType.purposeful && !t.isCompleted)
                        .length;
                    int necessaryCount = tasks
                        .where((t) =>
                            t.type == TaskType.necessary && !t.isCompleted)
                        .length;
                    int distractingCount = tasks
                        .where((t) =>
                            t.type == TaskType.distracting && !t.isCompleted)
                        .length;
                    int unnecessaryCount = tasks
                        .where((t) =>
                            t.type == TaskType.unnecessary && !t.isCompleted)
                        .length;

                    return [
                      _buildQuadrantCard(
                          context,
                          "Purposeful",
                          "$purposefulCount Tasks",
                          HyperfocusColors.purposeful,
                          Icons.star_outline),
                      _buildQuadrantCard(
                          context,
                          "Necessary",
                          "$necessaryCount Tasks",
                          HyperfocusColors.necessary,
                          Icons.check_circle_outline),
                      _buildQuadrantCard(
                          context,
                          "Distracting",
                          "$distractingCount Tasks",
                          HyperfocusColors.distracting,
                          Icons.notifications_none),
                      _buildQuadrantCard(
                          context,
                          "Unnecessary",
                          "$unnecessaryCount Tasks",
                          HyperfocusColors.unnecessary,
                          Icons.delete_outline),
                    ][index];
                  },
                  childCount: 4,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // AI Serendipity Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: HyperfocusColors.purposeful, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "AI Serendipity",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: HyperfocusColors.purposeful,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSerendipityCard(
                      "Dot Connection",
                      "Your 'Complete UI Implementation' task connects with your earlier 'Design System' work. Consider batching these for deeper flow.",
                      Icons.lightbulb_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildSerendipityCard(
                      "Pattern Detected",
                      "You're most productive on Purposeful tasks between 9-11 AM. Consider scheduling more deep work then.",
                      Icons.trending_up,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // AI Suggestion
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            HyperfocusColors.purposeful.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                    color: HyperfocusColors.purposeful.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: HyperfocusColors.purposeful),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Consider moving 'Email Triage' to Necessary batch work.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
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

  Widget _buildStat(
      BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HyperfocusColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuadrantProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time Distribution",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HyperfocusColors.textSecondary,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              _buildProgressSegment(HyperfocusColors.purposeful, 0.45),
              _buildProgressSegment(HyperfocusColors.necessary, 0.30),
              _buildProgressSegment(HyperfocusColors.distracting, 0.15),
              _buildProgressSegment(HyperfocusColors.unnecessary, 0.10),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegend(HyperfocusColors.purposeful, "Purposeful", "45%"),
            _buildLegend(HyperfocusColors.necessary, "Necessary", "30%"),
            _buildLegend(HyperfocusColors.distracting, "Distracting", "15%"),
            _buildLegend(HyperfocusColors.unnecessary, "Unnecessary", "10%"),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSegment(Color color, double fraction) {
    return Expanded(
      flex: (fraction * 100).toInt(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: fraction > 0.5
              ? const BorderRadius.horizontal(left: Radius.circular(4))
              : fraction < 0.1
                  ? const BorderRadius.horizontal(right: Radius.circular(4))
                  : null,
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, String percentage) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percentage,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HyperfocusColors.textSecondary,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildSerendipityCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: HyperfocusColors.purposeful.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HyperfocusColors.purposeful.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: HyperfocusColors.purposeful, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HyperfocusColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildQuadrantCard(BuildContext context, String title, String subtitle,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HyperfocusColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(delay: 100.ms).fadeIn();
  }
}
