import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FocusMode { hyperfocus, scatterfocus }

class FocusProvider with ChangeNotifier {
  // State
  bool _isFocusing = false;
  FocusMode _currentMode = FocusMode.hyperfocus;

  Duration _remainingTime = const Duration(minutes: 25);
  Timer? _timer;

  // Statistics
  int _totalSessions = 0;
  int _totalFocusMinutes = 0;
  int _currentStreak = 0;
  DateTime? _lastSessionDate;

  // Persistence
  late SharedPreferences _prefs;

  // Getters
  bool get isFocusing => _isFocusing;
  FocusMode get currentMode => _currentMode;
  Duration get remainingTime => _remainingTime;

  final List<Task> _tasks = [];

  // Load settings
  int get hyperfocusDuration {
    return _prefs.getInt('hyperfocusDuration') ?? 25;
  }

  int get scatterfocusDuration {
    return _prefs.getInt('scatterfocusDuration') ?? 15;
  }

  bool get hapticsEnabled {
    return _prefs.getBool('hapticsEnabled') ?? true;
  }

  // Statistics getters
  int get totalSessions => _totalSessions;
  int get totalFocusMinutes => _totalFocusMinutes;
  int get currentStreak => _currentStreak;

  List<Task> get tasks => _tasks;

  Task? get nextPurposefulTask =>
      _tasks.firstWhere((t) => t.type == TaskType.purposeful && !t.isCompleted,
          orElse: () => _tasks.isNotEmpty
              ? _tasks.first
              : Task(id: '0', title: 'No tasks', type: TaskType.necessary));

  double get cognitiveLoadScore {
    int uncompleted = _tasks.where((t) => !t.isCompleted).length;
    double baseLoad = (uncompleted * 0.1).clamp(0.0, 1.0);

    final hour = DateTime.now().hour;
    double circadianMultiplier = 1.0;
    if (hour >= 13 && hour <= 16) {
      circadianMultiplier = 1.2;
    } else if (hour >= 8 && hour <= 11) {
      circadianMultiplier = 0.8;
    }

    return (baseLoad * circadianMultiplier).clamp(0.0, 1.0);
  }

  FocusProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStatistics();
    _loadTasks();
    _calculateStreak();
  }

  Future<void> _loadStatistics() async {
    _totalSessions = _prefs.getInt('totalSessions') ?? 0;
    _totalFocusMinutes = _prefs.getInt('totalFocusMinutes') ?? 0;
    _currentStreak = _prefs.getInt('currentStreak') ?? 0;
    final lastDate = _prefs.getString('lastSessionDate');
    if (lastDate != null) {
      _lastSessionDate = DateTime.parse(lastDate);
    }
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    final tasksJson = _prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      _tasks.clear();
      _tasks.addAll(tasksList.map((t) => Task.fromJson(t)));
      notifyListeners();
    } else {
      // Default tasks
      _tasks.addAll([
        Task(
            id: '1',
            title: 'Complete UI Implementation',
            type: TaskType.purposeful),
        Task(id: '2', title: 'Email Triage', type: TaskType.necessary),
        Task(id: '3', title: 'Check Social Media', type: TaskType.distracting),
      ]);
    }
  }

  Future<void> _calculateStreak() async {
    if (_lastSessionDate == null) {
      _currentStreak = 0;
      return;
    }

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (_lastSessionDate!.year == today.year &&
        _lastSessionDate!.month == today.month &&
        _lastSessionDate!.day == today.day) {
      // Already logged today
      return;
    } else if (_lastSessionDate!.year == yesterday.year &&
        _lastSessionDate!.month == yesterday.month &&
        _lastSessionDate!.day == yesterday.day) {
      // Yesterday was the last session, streak continues
      return;
    } else {
      // Streak broken
      _currentStreak = 0;
      await _prefs.setInt('currentStreak', 0);
    }
  }

  Future<void> _saveStatistics() async {
    await _prefs.setInt('totalSessions', _totalSessions);
    await _prefs.setInt('totalFocusMinutes', _totalFocusMinutes);
    await _prefs.setInt('currentStreak', _currentStreak);
    if (_lastSessionDate != null) {
      await _prefs.setString('lastSessionDate', _lastSessionDate!.toIso8601String());
    }
  }

  Future<void> _saveTasks() async {
    final tasksJson = json.encode(_tasks.map((t) => t.toJson()).toList());
    await _prefs.setString('tasks', tasksJson);
  }

  void _triggerHaptic(HapticFeedbackType type) {
    if (hapticsEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void startFocusSession({FocusMode mode = FocusMode.hyperfocus}) {
    if (_isFocusing) return;

    _currentMode = mode;
    _isFocusing = true;

    final duration = mode == FocusMode.hyperfocus
        ? Duration(minutes: hyperfocusDuration)
        : Duration(minutes: scatterfocusDuration);
    _remainingTime = duration;

    notifyListeners();
    _triggerHaptic(HapticFeedbackType.mediumImpact);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        notifyListeners();
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _isFocusing = false;

    // Update statistics
    final sessionMinutes = _currentMode == FocusMode.hyperfocus
        ? hyperfocusDuration
        : scatterfocusDuration;
    _totalSessions++;
    _totalFocusMinutes += sessionMinutes;
    _lastSessionDate = DateTime.now();

    // Update streak
    final today = DateTime.now();
    if (_lastSessionDate!.year == today.year &&
        _lastSessionDate!.month == today.month &&
        _lastSessionDate!.day == today.day) {
      // Already counted today, don't increment
    } else {
      _currentStreak++;
    }

    _saveStatistics();
    _triggerHaptic(HapticFeedbackType.heavyImpact);

    _remainingTime = Duration(minutes: hyperfocusDuration);
    notifyListeners();
  }

  void stopFocusSession() {
    if (!_isFocusing) return;

    _timer?.cancel();
    _isFocusing = false;
    _remainingTime = Duration(minutes: hyperfocusDuration);
    _triggerHaptic(HapticFeedbackType.lightImpact);
    notifyListeners();
  }

  void addTask(String title) {
    TaskType type = TaskType.necessary;
    if (title.toLowerCase().contains('focus') ||
        title.toLowerCase().contains('plan') ||
        title.toLowerCase().contains('implement') ||
        title.toLowerCase().contains('create')) {
      type = TaskType.purposeful;
    } else if (title.toLowerCase().contains('game') ||
        title.toLowerCase().contains('twitter') ||
        title.toLowerCase().contains('facebook') ||
        title.toLowerCase().contains('instagram')) {
      type = TaskType.distracting;
    } else if (title.toLowerCase().contains('maybe') ||
        title.toLowerCase().contains('someday') ||
        title.toLowerCase().contains('later')) {
      type = TaskType.unnecessary;
    }

    _tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
    ));
    _saveTasks();
    notifyListeners();
  }

  void completeTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = true;
      _saveTasks();
      _triggerHaptic(HapticFeedbackType.mediumImpact);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(String id, String newTitle, TaskType newType) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = Task(
        id: _tasks[index].id,
        title: newTitle,
        type: newType,
        isCompleted: _tasks[index].isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    _saveTasks();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

extension on Task {
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.index,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        type: TaskType.values[json['type']],
        isCompleted: json['isCompleted'],
      );
}
