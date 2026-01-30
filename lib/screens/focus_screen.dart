import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/widgets/focus_ritual_sheet.dart';

import 'package:provider/provider.dart';
import 'package:productivity_app/providers/focus_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Attention Meter (Cognitive Load)
              _buildAttentionMeter(context),

              // Next Purposeful Task
              _buildTaskCard(context),

              // Start Focus Button (Breathing)
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttentionMeter(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final cognitiveLoad = focusProvider.cognitiveLoadScore;
    final loadColor = _getLoadColor(cognitiveLoad);

    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: cognitiveLoad,
                backgroundColor: HyperfocusColors.surfaceHighlight,
                color: loadColor,
                strokeWidth: 8,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (focusProvider.isFocusing) ...[
                      Text(
                        _formatDuration(focusProvider.remainingTime),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: HyperfocusColors.purposeful,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        "REMAINING",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: HyperfocusColors.purposeful
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                    ] else ...[
                      Text(
                        "${(cognitiveLoad * 100).toInt()}%",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: loadColor,
                            ),
                      ),
                      Text(
                        _getLoadLabel(cognitiveLoad),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: loadColor.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Cognitive Load",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: HyperfocusColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Color _getLoadColor(double load) {
    if (load < 0.4) return HyperfocusColors.purposeful; // Green
    if (load < 0.7) return HyperfocusColors.necessary; // Blue
    if (load < 0.9) return HyperfocusColors.distracting; // Orange
    return HyperfocusColors.unnecessary; // Red
  }

  String _getLoadLabel(double load) {
    if (load < 0.4) return "Clear";
    if (load < 0.7) return "Moderate";
    if (load < 0.9) return "High";
    return "Overloaded";
  }

  Widget _buildTaskCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: HyperfocusColors.purposeful, size: 20),
              const SizedBox(width: 8),
              Text(
                "NEXT PURPOSEFUL TASK",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: HyperfocusColors.purposeful,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Complete UI Implementation Plan",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create detailed plan for Focus, Capture, and Review screens.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HyperfocusColors.textSecondary,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HyperfocusColors.purposeful, Color(0xFF00C853)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: HyperfocusColors.purposeful.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (context.read<FocusProvider>().isFocusing) {
            context.read<FocusProvider>().stopFocusSession();
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const FocusRitualSheet(),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Text(
          context.watch<FocusProvider>().isFocusing
              ? "STOP SESSION"
              : "START HYPERFOCUS",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black, // Dark text on bright button for contrast
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 2000.ms,
            curve: Curves.easeInOut) // Breathing effect
        .then()
        .boxShadow(
          begin: BoxShadow(
              color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 0),
          end: BoxShadow(
              color: HyperfocusColors.purposeful
                  .withValues(alpha: 0.8), // Enhanced Glow
              blurRadius: 35, // Wider blur
              spreadRadius: 8), // Wider spread
          duration: 2000.ms,
        );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
