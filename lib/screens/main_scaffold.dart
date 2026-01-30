import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:productivity_app/screens/focus_screen.dart';
import 'package:productivity_app/screens/capture_screen.dart';
import 'package:productivity_app/screens/review_screen.dart';
import 'package:productivity_app/utils/theme.dart';
import 'package:productivity_app/screens/settings_screen.dart';
import 'package:productivity_app/providers/focus_provider.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getRandomQuote() {
    return _motivationalQuotes[_selectedIndex % _motivationalQuotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FocusProvider>();

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
          // Energy indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getEnergyColor(provider.currentEnergyLevel).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _getEnergyIcon(provider.currentEnergyLevel),
                  color: _getEnergyColor(provider.currentEnergyLevel),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _getEnergyLabel(provider.currentEnergyLevel),
                  style: TextStyle(
                    color: _getEnergyColor(provider.currentEnergyLevel),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
        return Color(0xFF00E676);
    }
  }

  IconData _getEnergyIcon(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.exhausted:
        return Icons.battery_1_bar;
      case EnergyLevel.low:
        return Icons.battery_3_bar;
      case EnergyLevel.moderate:
        return Icons.battery_5_bar;
      case EnergyLevel.high:
        return Icons.battery_6_bar;
      case EnergyLevel.peak:
        return Icons.battery_full;
    }
  }

  String _getEnergyLabel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.exhausted:
        return "Low";
      case EnergyLevel.low:
        return "Low";
      case EnergyLevel.moderate:
        return "OK";
      case EnergyLevel.high:
        return "High";
      case EnergyLevel.peak:
        return "Peak";
    }
  }
}
