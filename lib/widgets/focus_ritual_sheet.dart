import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:provider/provider.dart';

class FocusRitualSheet extends StatefulWidget {
  const FocusRitualSheet({super.key});

  @override
  State<FocusRitualSheet> createState() => _FocusRitualSheetState();
}

class _FocusRitualSheetState extends State<FocusRitualSheet> {
  String _intention = "";
  FocusMode _selectedMode = FocusMode.hyperfocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
              color: HyperfocusColors.purposeful.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Focus Ritual",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Set your intention before you begin.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HyperfocusColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // Mode Selection
          Text("MODE", style: _labelStyle(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildModeChip(
                  FocusMode.hyperfocus, "Hyperfocus", Icons.flash_on),
              const SizedBox(width: 12),
              _buildModeChip(
                  FocusMode.scatterfocus, "Scatterfocus", Icons.auto_awesome),
            ],
          ),
          const SizedBox(height: 24),

          // Intention Input
          Text("INTENTION", style: _labelStyle(context)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _intention = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "What is your single visualizable goal?",
              hintStyle: TextStyle(
                  color: HyperfocusColors.textSecondary.withValues(alpha: 0.5)),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _intention.isNotEmpty
                  ? () {
                      context
                          .read<FocusProvider>()
                          .startFocusSession(mode: _selectedMode);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMode == FocusMode.hyperfocus
                    ? HyperfocusColors.purposeful
                    : HyperfocusColors.necessary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _selectedMode == FocusMode.hyperfocus
                    ? "Enter Hyperfocus"
                    : "Start Scatterfocus",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModeChip(FocusMode mode, String label, IconData icon) {
    final isSelected = _selectedMode == mode;
    final color = mode == FocusMode.hyperfocus
        ? HyperfocusColors.purposeful
        : HyperfocusColors.necessary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle? _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          color: HyperfocusColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );
  }
}
