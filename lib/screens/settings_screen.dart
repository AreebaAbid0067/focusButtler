import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:productivity_app/models/task.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current provider value if available
    // We need to wait for the build to complete to access provider safely if needed immediately
    // or just let the build method handle the initial population
    // But since text controller needs init:
    _nameController.text =
        "Focus User"; // Default placeholder, will act as "local" state until saved
    // Real sync happens via build method reading from provider
  }

  // We'll update the controller text once when provider data is ready
  bool _isControllerInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider for changes
    final provider = context.watch<FocusProvider>();

    // Sync controller once
    if (!_isControllerInitialized && provider.userName != null) {
      _nameController.text = provider.userName!;
      _isControllerInitialized = true;
    }

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: HyperfocusColors.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Profile"),
            _buildProfileCard(provider),
            const SizedBox(height: 32),
            _buildSectionHeader("Focus Settings"),
            _buildFocusDurationCard(provider),
            const SizedBox(height: 32),
            _buildSectionHeader("Preferences"),
            _buildPreferencesCard(provider),
            const SizedBox(height: 32),
            _buildSectionHeader("Data"),
            _buildDataCard(provider),
            const SizedBox(height: 32),
            _buildSectionHeader("About"),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HyperfocusColors.purposeful,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProfileCard(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: HyperfocusColors.purposeful.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'F',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HyperfocusColors.purposeful,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    labelStyle:
                        TextStyle(color: HyperfocusColors.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) => provider.setUserName(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow("Total Sessions", "${provider.totalSessions}"),
          _buildStatRow("Total Focus Time", "${provider.totalFocusMinutes} m"),
          _buildStatRow("Current Streak", "${provider.currentStreak} days"),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: HyperfocusColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusDurationCard(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildSliderSetting(
            "Hyperfocus Duration",
            provider.hyperfocusDuration.inMinutes,
            15,
            60,
            "min",
            Icons.flash_on,
            HyperfocusColors.purposeful,
            (value) => provider.setHyperfocusDuration(value.toInt()),
          ),
          const SizedBox(height: 24),
          _buildSliderSetting(
            "Scatterfocus Duration",
            provider.scatterfocusDuration.inMinutes,
            5,
            30,
            "min",
            Icons.auto_awesome,
            HyperfocusColors.necessary,
            (value) => provider.setScatterfocusDuration(value.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    int value,
    int min,
    int max,
    String unit,
    IconData icon,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              "$value $unit",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min),
          activeColor: color,
          inactiveColor: HyperfocusColors.surfaceHighlight,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPreferencesCard(FocusProvider provider) {
    // Note: Provider needs getters for these. Assume they exist or defaults.
    // Since we added setters, we should ensure getters match.
    // The provider currently has 'hapticsEnabled'.
    // We need to add 'notificationsEnabled' getter to Provider or assume default true.
    // Checking Provider code... it has hapticsEnabled.
    // It does not explicitly expose notificationsEnabled as a getter yet, only via SharedPreferences internal.
    // We should add that getter to provider for full correctness, or reading from prefs.
    // For now we'll assume haptics works and mock notifications or use a standard value.

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildToggleSetting(
            "Notifications",
            "Get reminded to take breaks",
            Icons.notifications,
            provider.notificationsEnabled,
            (value) => provider.setNotificationsEnabled(value),
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            "Haptic Feedback",
            "Vibrate on interactions",
            Icons.vibration,
            provider.hapticsEnabled,
            (value) => provider.setHapticsEnabled(value),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: HyperfocusColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: HyperfocusColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: HyperfocusColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: HyperfocusColors.purposeful,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDataCard(FocusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildActionRow(
            "Export Data",
            "Download your focus history and patterns",
            Icons.download,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming soon')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionRow(
            "Productivity Patterns",
            "View your energy and attention analytics",
            Icons.analytics,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'View your productivity patterns in the Review screen')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionRow(
            "Clear All Data",
            "Reset all progress and settings",
            Icons.delete_forever,
            () => _showClearDataDialog(provider),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive
                  ? HyperfocusColors.unnecessary.withOpacity(0.2)
                  : HyperfocusColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? HyperfocusColors.unnecessary
                  : HyperfocusColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? HyperfocusColors.unnecessary
                        : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: HyperfocusColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: HyperfocusColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(FocusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HyperfocusColors.surface,
        title: const Text("Clear All Data?"),
        content: const Text(
          "This will delete all your tasks, focus sessions, and settings. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: HyperfocusColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: HyperfocusColors.unnecessary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: HyperfocusColors.purposeful,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hyperfocus",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: HyperfocusColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Master your attention. Toggle between Hyperfocus for deep work and Scatterfocus for creative thinking.",
            style: TextStyle(
              color: HyperfocusColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
