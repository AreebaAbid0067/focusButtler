import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:provider/provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isVoiceMode = true;
  bool _isListening = false;

  void _submitTask() {
    if (_taskController.text.isNotEmpty) {
      context.read<FocusProvider>().addTask(_taskController.text);
      _taskController.clear();
      _showCaptureNotification();
    }
  }

  void _showCaptureNotification() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: HyperfocusColors.necessary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Captured to Brain Dump',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn()
              .slideY(begin: -0.2, end: 0)
              .then()
              .fadeOut(delay: 1500.ms),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  void _toggleListening() {
    setState(() {
      _isListening = true;
    });

    // Simulate Voice Recognition Delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      context
          .read<FocusProvider>()
          .addTask("Simulated Voice Task ${DateTime.now().second}");
      _showCaptureNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darker than default for "Sanctuary" feel
      body: Stack(
        children: [
          // Background Gradient Mesh (Subtle)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    HyperfocusColors.necessary.withValues(alpha: 0.1),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Mode Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HyperfocusColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeButton(Icons.mic, true),
                      _buildModeButton(Icons.keyboard, false),
                    ],
                  ),
                ),

                const Spacer(),

                // Main Interaction Area
                SizedBox(
                  height: 200, // Fixed height area for stability
                  child: Center(
                    child: _isVoiceMode
                        ? _buildVoiceInterface()
                        : _buildTextInterface(),
                  ),
                ),

                const Spacer(),

                // Hint Text
                Text(
                  _isVoiceMode
                      ? (_isListening ? "Listening..." : "Tap to Speak")
                      : "Type to unload",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _isListening
                            ? Colors.white
                            : HyperfocusColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                ).animate(target: _isListening ? 1 : 0).fadeIn(),

                const Spacer(),

                // Helper Info
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    "Capture ideas instantly.\nAI will sort them later.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HyperfocusColors.textTertiary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(IconData icon, bool isVoice) {
    final isSelected = _isVoiceMode == isVoice;
    return GestureDetector(
      onTap: () => setState(() => _isVoiceMode = isVoice),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? HyperfocusColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : HyperfocusColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildVoiceInterface() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: 200.ms,
        width: _isListening ? 180 : 160,
        height: _isListening ? 180 : 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening
              ? HyperfocusColors.necessary
              : HyperfocusColors.surfaceHighlight,
          boxShadow: [
            if (_isListening)
              BoxShadow(
                color: HyperfocusColors.necessary.withValues(alpha: 0.5),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: _isListening
                ? Colors.white
                : Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: _isListening
            ? _buildSoundWave()
            : Icon(Icons.mic_none, size: 64, color: Colors.white),
      ),
    ).animate().scale(delay: 100.ms).fadeIn();
  }

  Widget _buildSoundWave() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              width: 8,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleY(
                  begin: 0.3,
                  end: 0.8 + (index * 0.1),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeInOut,
                ),
          );
        }),
      ),
    );
  }

  Widget _buildTextInterface() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: "Dump your thought here...",
                hintStyle: TextStyle(
                    color:
                        HyperfocusColors.textSecondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _submitTask(),
            ),
          ),
          IconButton(
            onPressed: _submitTask,
            icon: const Icon(Icons.arrow_upward_rounded),
            color: HyperfocusColors.purposeful,
            style: IconButton.styleFrom(
              backgroundColor: HyperfocusColors.surfaceHighlight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}
