import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/widgets/focus_ritual_sheet.dart';
import 'package:provider/provider.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:hyperfocus_server_client/hyperfocus_server_client.dart';
import 'dart:ui';

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

              // Next Purposeful Task (AI-Recommended)
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
                          color: loadColor,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        "REMAINING",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: loadColor.withValues(alpha: 0.7),
                            ),
                      ),
                    ] else ...[
                      Text(
                        "${(focusProvider.attentionScore * 100).toInt()}%",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: loadColor,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        "ATTENTION",
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
        ).animate(target: focusProvider.isFocusing ? 1.0 : 0.0).scale(),
        const SizedBox(height: 16),
        Text(
          focusProvider.isFocusing
              ? (focusProvider.currentMode == FocusMode.hyperfocus
                  ? "Hyperfocus Active"
                  : "Scatterfocus Active")
              : "Focus Potential",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HyperfocusColors.textSecondary,
                letterSpacing: 2.0,
              ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    final provider = context.watch<FocusProvider>();
    final Task? currentTask = provider.tasks.isNotEmpty
        ? provider.tasks.firstWhere((t) => !t.isCompleted,
            orElse: () => provider.tasks.first)
        : null;

    if (currentTask == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: HyperfocusColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text(
            "No tasks planned.\nCapture something to focus on.",
            textAlign: TextAlign.center,
            style: TextStyle(color: HyperfocusColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HyperfocusColors.purposeful.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star,
                  color: HyperfocusColors.purposeful, size: 16),
              const SizedBox(width: 8),
              Text(
                "NEXT CRITICAL TASK",
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
            currentTask.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          _buildEnergyBadge(context, provider.currentEnergyLevel),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0);
  }

  Widget _buildStartButton(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final isFocusing = focusProvider.isFocusing;

    return GestureDetector(
      onLongPress: () {
        if (!isFocusing) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FocusRitualSheet(),
          );
        }
      },
      onTap: () {
        if (!isFocusing) {
          HapticFeedback.heavyImpact();
          // Default to hyperfocus on tap for now
          focusProvider.startFocusSession(mode: FocusMode.hyperfocus);
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: 800.ms,
            width: isFocusing ? 200 : 160,
            height: isFocusing ? 200 : 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isFocusing ? Colors.transparent : HyperfocusColors.purposeful,
              border: Border.all(
                color: HyperfocusColors.purposeful,
                width: isFocusing ? 2 : 0,
              ),
              boxShadow: [
                if (!isFocusing)
                  BoxShadow(
                    color: HyperfocusColors.purposeful.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Center(
              child: isFocusing
                  ? _buildPulsatingCircle()
                  : const Text(
                      "FOCUS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2000.ms),
          const SizedBox(height: 24),
          Text(
            isFocusing
                ? "Tap the phone to log a distraction"
                : "LONG PRESS FOR RITUAL",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HyperfocusColors.textSecondary,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsatingCircle() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(2.5, 2.5),
            duration: 2000.ms)
        .fadeOut(duration: 2000.ms);
  }

  Widget _buildEnergyBadge(BuildContext context, EnergyLevel level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HyperfocusColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: _getEnergyColor(level), size: 14),
          const SizedBox(width: 4),
          Text(
            level.name.toUpperCase(),
            style: TextStyle(
              color: _getEnergyColor(level),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLoadColor(double load) {
    if (load < 0.3) return HyperfocusColors.purposeful;
    if (load < 0.7) return HyperfocusColors.necessary;
    return HyperfocusColors.distracting;
  }

  Color _getEnergyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.exhausted:
        return HyperfocusColors.unnecessary;
      case EnergyLevel.low:
        return HyperfocusColors.distracting;
      case EnergyLevel.moderate:
        return HyperfocusColors.necessary;
      case EnergyLevel.high:
        return HyperfocusColors.purposeful;
      case EnergyLevel.peak:
        return const Color(0xFF00E676);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
