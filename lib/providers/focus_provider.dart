import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyperfocus_server_client/hyperfocus_server_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

extension EnergyLevelExtension on EnergyLevel {
  double get multiplier {
    switch (this) {
      case EnergyLevel.exhausted:
        return 0.5;
      case EnergyLevel.low:
        return 0.8;
      case EnergyLevel.moderate:
        return 1.0;
      case EnergyLevel.high:
        return 1.3;
      case EnergyLevel.peak:
        return 1.5;
    }
  }
}

extension AIInsightExtension on AIInsight {
  String get label {
    switch (category.toLowerCase()) {
      case 'productivity':
        return 'Focus';
      case 'energy':
        return 'Energy';
      case 'attention':
        return 'Attention';
      case 'tasks':
        return 'Planning';
      default:
        return 'Insight';
    }
  }
}

class FocusProvider with ChangeNotifier {
  late Client _client;
  late SharedPreferences _prefs;

  List<Task> _tasks = [];
  List<EnergyEntry> _energyHistory = [];
  List<AIInsight> _aiInsights = [];
  Map<int, EnergyLevel> _productivityPatterns = {};

  EnergyLevel _currentEnergyLevel = EnergyLevel.moderate;
  FocusMode _currentMode = FocusMode.hyperfocus;
  String? _currentSessionId;

  // Settings
  String? _userName;
  Duration _hyperfocusDuration = const Duration(minutes: 25);
  Duration _scatterfocusDuration = const Duration(minutes: 15);
  bool _hapticsEnabled = true;
  bool _notificationsEnabled = true;

  bool _isFocusing = false;
  Duration _remainingTime = const Duration(minutes: 25);
  double _attentionScore = 1.0;
  int _distractionCount = 0;
  int _sessionCount = 0;
  bool _isLoading = true;
  bool _isConnected = false;
  Timer? _timer;

  FocusProvider() {
    _init();
  }

  // Getters
  List<Task> get tasks => _tasks;
  List<EnergyEntry> get energyHistory => _energyHistory;
  List<AIInsight> get aiInsights => _aiInsights;
  EnergyLevel get currentEnergyLevel => _currentEnergyLevel;
  FocusMode get currentMode => _currentMode;
  bool get isFocusing => _isFocusing;
  Duration get remainingTime => _remainingTime;
  double get attentionScore => _attentionScore;
  int get distractionCount => _distractionCount;
  int get totalSessions => _sessionCount;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;

  String? get userName => _userName;
  Duration get hyperfocusDuration => _hyperfocusDuration;
  Duration get scatterfocusDuration => _scatterfocusDuration;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  double get cognitiveLoadScore {
    if (_isFocusing) {
      final total = _currentMode == FocusMode.hyperfocus
          ? _hyperfocusDuration.inSeconds
          : _scatterfocusDuration.inSeconds;
      return (_remainingTime.inSeconds / total).clamp(0.0, 1.0);
    }
    return _attentionScore;
  }

  int get totalFocusMinutes {
    return _sessionCount * 25; // Simplified for now
  }

  int get currentStreak => 3; // Mocked

  Future<void> _init() async {
    _client = Client(
      'http://localhost:8080/',
    )..connectivityMonitor = FlutterConnectivityMonitor();

    _prefs = await SharedPreferences.getInstance();
    _loadSettings();

    try {
      await _loadTasks();
      await _loadEnergyData();
      await _loadProductivityPatterns();
      await _loadInsights();
      _isConnected = true;
    } catch (e) {
      debugPrint('Failed to connect to backend: $e');
      _isConnected = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadSettings() {
    _userName = _prefs.getString('user_name') ?? 'Focus User';
    _hapticsEnabled = _prefs.getBool('haptics_enabled') ?? true;
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
    _hyperfocusDuration =
        Duration(minutes: _prefs.getInt('hyperfocus_duration') ?? 25);
    _scatterfocusDuration =
        Duration(minutes: _prefs.getInt('scatterfocus_duration') ?? 15);
  }

  Future<void> _loadTasks() async {
    _tasks = await _client.task.getAll();
    notifyListeners();
  }

  Future<void> _loadEnergyData() async {
    _energyHistory = await _client.energy.getToday();
    final current = await _client.energy.getCurrent();
    if (current != null) {
      _currentEnergyLevel = current.level;
    }
    notifyListeners();
  }

  Future<void> _loadProductivityPatterns() async {
    _productivityPatterns = await _client.energy.getHourlyPatterns();
    notifyListeners();
  }

  Future<void> _loadInsights() async {
    _aiInsights = await _client.agent.getActiveInsights();
    notifyListeners();
  }

  // Settings Actions
  void setUserName(String name) {
    _userName = name;
    _prefs.setString('user_name', name);
    notifyListeners();
  }

  void setHyperfocusDuration(int minutes) {
    _hyperfocusDuration = Duration(minutes: minutes);
    _prefs.setInt('hyperfocus_duration', minutes);
    notifyListeners();
  }

  void setScatterfocusDuration(int minutes) {
    _scatterfocusDuration = Duration(minutes: minutes);
    _prefs.setInt('scatterfocus_duration', minutes);
    notifyListeners();
  }

  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
    _prefs.setBool('haptics_enabled', enabled);
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    _prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
    _loadSettings();
    _tasks.clear();
    _energyHistory.clear();
    _aiInsights.clear();
    _sessionCount = 0;
    // Note: Backend clear would be needed here for full reset
    notifyListeners();
  }

  // Task Actions
  Future<void> addTask(String title) async {
    try {
      final type = await _client.agent.categorizeTask(title);
      final task = await _client.task.create(title, type);
      _tasks.add(task);
      notifyListeners();

      final insight = await _client.agent.getCoachingInsight(
        'User added a new ${type.name} task: \"$title\".',
      );
      _aiInsights.insert(0, insight);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add task: $e');
    }
  }

  Future<void> completeTask(String id) async {
    try {
      final updated = await _client.task.complete(id);
      if (updated != null) {
        final i = _tasks.indexWhere((t) => t.id == id);
        if (i != -1) {
          _tasks[i] = updated;
          _triggerHaptic(HapticFeedbackType.medium);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error completing task: $e');
    }
  }

  Future<void> uncompleteTask(String id) async {
    try {
      final updated = await _client.task.uncomplete(id);
      if (updated != null) {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasks[index] = updated;
          _triggerHaptic(HapticFeedbackType.light);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error uncompleting task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final success = await _client.task.delete(id);
      if (success) {
        _tasks.removeWhere((t) => t.id == id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Energy Actions
  Future<void> logEnergy(EnergyLevel level) async {
    try {
      final entry = await _client.energy.logEnergy(level);
      _energyHistory.add(entry);
      _currentEnergyLevel = level;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to log energy: $e');
    }
  }

  // Focus Session Actions
  Future<void> startFocusSession(
      {FocusMode mode = FocusMode.hyperfocus}) async {
    if (_isFocusing) return;
    _currentMode = mode;
    _isFocusing = true;
    _attentionScore = 1.0;
    _distractionCount = 0;

    final duration = mode == FocusMode.hyperfocus
        ? _hyperfocusDuration
        : _scatterfocusDuration;
    _remainingTime = duration;

    try {
      final session =
          await _client.session.startSession(mode, duration.inMinutes);
      _currentSessionId = session.id;
    } catch (e) {
      debugPrint('Error starting session: $e');
    }

    notifyListeners();
    _triggerHaptic(HapticFeedbackType.medium);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        notifyListeners();
      } else {
        _completeSession(true);
      }
    });
  }

  Future<void> logDistraction() async {
    _distractionCount++;
    if (_currentSessionId != null) {
      try {
        await _client.session.logDistraction(_currentSessionId!);
      } catch (e) {
        debugPrint('Error logging distraction: $e');
      }
    }
    _attentionScore = (_attentionScore - 0.1).clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> _completeSession(bool wasCompleted) async {
    _timer?.cancel();
    _isFocusing = false;
    _sessionCount++;

    if (_currentSessionId != null) {
      try {
        await _client.session
            .endSession(_currentSessionId!, wasCompleted: wasCompleted);
      } catch (e) {
        debugPrint('Error ending session: $e');
      }
    }

    _triggerHaptic(HapticFeedbackType.heavy);
    _remainingTime = Duration(minutes: _hyperfocusDuration.inMinutes);
    _currentSessionId = null;
    notifyListeners();
  }

  void stopFocusSession() {
    _completeSession(false);
  }

  // Helper Methods
  void _triggerHaptic(HapticFeedbackType type) {
    if (!_hapticsEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}

enum HapticFeedbackType { light, medium, heavy }
