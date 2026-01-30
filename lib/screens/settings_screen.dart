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
  int _hyperfocusDuration = 25;
  int _scatterfocusDuration = 15;
  bool _notificationsEnabled = true;
  bool _hapticsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? 'Focus User';
      _hyperfocusDuration = prefs.getInt('hyperfocusDuration') ?? 25;
      _scatterfocusDuration = prefs.getInt('scatterfocusDuration') ?? 15;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setInt('hyperfocusDuration', _hyperfocusDuration);
    await prefs.setInt('scatterfocusDuration', _scatterfocusDuration);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _nameController.text = 'Focus User';
    setState(() {
      _hyperfocusDuration = 25;
      _scatterfocusDuration = 15;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            _buildProfileCard(),
            const SizedBox(height: 32),

            _buildSectionHeader("Focus Settings"),
            _buildFocusDurationCard(),
            const SizedBox(height: 32),

            _buildSectionHeader("Preferences"),
            _buildPreferencesCard(),
            const SizedBox(height: 32),

            _buildSectionHeader("Data"),
            _buildDataCard(),
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

  Widget _buildProfileCard() {
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: HyperfocusColors.purposeful.withValues(alpha: 0.2),
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
                    labelStyle: TextStyle(color: HyperfocusColors.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) => _saveSettings(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow("Total Sessions", "12"),
          _buildStatRow("Total Focus Time", "4h 32m"),
          _buildStatRow("Current Streak", "5 days"),
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

  Widget _buildFocusDurationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildSliderSetting(
            "Hyperfocus Duration",
            _hyperfocusDuration,
            15,
            60,
            "min",
            Icons.flash_on,
            HyperfocusColors.purposeful,
            (value) {
              setState(() => _hyperfocusDuration = value.toInt());
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),
          _buildSliderSetting(
            "Scatterfocus Duration",
            _scatterfocusDuration,
            5,
            30,
            "min",
            Icons.auto_awesome,
            HyperfocusColors.necessary,
            (value) {
              setState(() => _scatterfocusDuration = value.toInt());
              _saveSettings();
            },
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

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildToggleSetting(
            "Notifications",
            "Get reminded to take breaks",
            Icons.notifications,
            _notificationsEnabled,
            (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildToggleSetting(
            "Haptic Feedback",
            "Vibrate on interactions",
            Icons.vibration,
            _hapticsEnabled,
            (value) {
              setState(() => _hapticsEnabled = value);
              _saveSettings();
            },
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

  Widget _buildDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HyperfocusColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                const SnackBar(content: Text('View your productivity patterns in the Review screen')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionRow(
            "Clear All Data",
            "Reset all progress and settings",
            Icons.delete_forever,
            () => _showClearDataDialog(),
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
                  ? HyperfocusColors.unnecessary.withValues(alpha: 0.2)
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

  void _showClearDataDialog() {
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
              _clearAllData();
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
