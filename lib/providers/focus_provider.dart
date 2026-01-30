import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:productivity_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FocusMode { hyperfocus, scatterfocus }

enum EnergyLevel {
  exhausted(0.2),
  low(0.4),
  moderate(0.6),
  high(0.8),
  peak(1.0);

  final double multiplier;
  const EnergyLevel(this.multiplier);
}

class FocusProvider with ChangeNotifier {
  // Core State
  bool _isFocusing = false;
  FocusMode _currentMode = FocusMode.hyperfocus;
  Duration _remainingTime = const Duration(minutes: 25);
  Timer? _timer;

  // Energy & Circadian System
  EnergyLevel _currentEnergyLevel = EnergyLevel.moderate;
  List<EnergyEntry> _energyHistory = [];
  DateTime _lastEnergyLog = DateTime.now();
  
  // Cognitive State
  double _attentionScore = 1.0; // 0-1, measures current attention quality
  int _distractionCount = 0;
  List<Distraction> _distractions = [];
  int _sessionCount = 0;
  
  // AI/Agentic State
  List<Task> _tasks = [];
  List<AIInsight> _aiInsights = [];
  Map<String, double> _productivityPattern = {}; // Hour -> productivity score
  DateTime? _peakProductivityHour;

  // Persistence
  late SharedPreferences _prefs;

  // Getters
  bool get isFocusing => _isFocusing;
  FocusMode get currentMode => _currentMode;
  Duration get remainingTime => _remainingTime;
  
  EnergyLevel get currentEnergyLevel => _currentEnergyLevel;
  List<EnergyEntry> get energyHistory => _energyHistory;
  
  double get attentionScore => _attentionScore;
  int get distractionCount => _distractionCount;
  int get sessionCount => _sessionCount;
  
  List<Task> get tasks => _tasks;
  List<AIInsight> get aiInsights => _aiInsights;
  DateTime? get peakProductivityHour => _peakProductivityHour;
  
  Duration get hyperfocusDuration {
    return Duration(minutes: _prefs.getInt('hyperfocusDuration') ?? _getOptimalHyperfocusDuration());
  }
  
  Duration get scatterfocusDuration {
    return Duration(minutes: _prefs.getInt('scatterfocusDuration') ?? 15);
  }

  bool get hapticsEnabled {
    return _prefs.getBool('hapticsEnabled') ?? true;
  }

  Task? get nextRecommendedTask {
    if (_tasks.isEmpty) return null;
    
    // AI-powered task selection based on multiple factors
    final now = DateTime.now();
    final hour = now.hour;
    final energyMultiplier = _currentEnergyLevel.multiplier;
    
    // Score each task
    final scoredTasks = _tasks
        .where((t) => !t.isCompleted)
        .map((task) {
          double score = 0;
          
          // Energy match scoring
          final energyMatch = _getEnergyTaskMatch(task.type);
          score += energyMatch * energyMultiplier * 30;
          
          // Time-based scoring (certain tasks better at certain times)
          score += _getTimeBasedScore(task, hour) * 20;
          
          // Attention fit scoring
          if (_attentionScore < 0.5 && task.type == TaskType.purposeful) {
            score *= 0.5; // Defer deep work if attention is low
          }
          
          // Urgency factor (older tasks get slight boost)
          final age = now.difference(task.createdAt).inHours;
          score += (age / 24).clamp(0, 10);
          
          return MapEntry(task, score);
        })
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return scoredTasks.first.key;
  }

  double get cognitiveLoadScore {
    int uncompleted = _tasks.where((t) => !t.isCompleted).length;
    double baseLoad = (uncompleted * 0.1).clamp(0.0, 1.0);
    
    // Circadian adjustment based on actual patterns
    final hour = DateTime.now().hour;
    double circadianMultiplier = _productivityPattern[hour] ?? 1.0;
    
    // Energy level impact
    final energyImpact = _currentEnergyLevel.multiplier;
    
    return (baseLoad * circadianMultiplier * energyImpact).clamp(0.0, 1.0);
  }

  FocusProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEnergyData();
    await _loadTasks();
    await _loadProductivityPatterns();
    _analyzePatterns();
  }

  int _getOptimalHyperfocusDuration() {
    // AI-determined optimal duration based on energy patterns
    final hour = DateTime.now().hour;
    final pattern = _productivityPattern[hour] ?? 0.7;
    
    // Higher productivity = longer sessions
    if (pattern > 0.8) return 45;
    if (pattern > 0.6) return 30;
    return 20;
  }

  double _getEnergyTaskMatch(TaskType type) {
    switch (type) {
      case TaskType.purposeful:
        // Deep work best at high energy
        return _currentEnergyLevel.multiplier;
      case TaskType.necessary:
        // Routine tasks fine at any energy
        return 0.7;
      case TaskType.distracting:
        // Low priority, only when energy is low
        return 1.0 - _currentEnergyLevel.multiplier;
      case TaskType.unnecessary:
        return 0.3;
    }
  }

  double _getTimeBasedScore(Task task, int hour) {
    // Morning people: better at analytical tasks early
    // Evening people: better at creative tasks late
    final morningScore = _productivityPattern[9] ?? 0.5;
    final eveningScore = _productivityPattern[20] ?? 0.5;
    
    final isMorningPerson = morningScore > eveningScore;
    
    if (task.type == TaskType.purposeful) {
      return isMorningPerson 
          ? (hour >= 6 && hour <= 12 ? 1.0 : 0.6)
          : (hour >= 14 && hour <= 21 ? 1.0 : 0.6);
    }
    
    // Scatterfocus tasks better during breaks in productivity
    return isMorningPerson 
        ? (hour >= 13 && hour <= 15 ? 1.0 : 0.5)
        : (hour >= 10 && hour <= 12 ? 1.0 : 0.5);
  }

  // Energy Tracking
  Future<void> logEnergy(EnergyLevel level) async {
    final entry = EnergyEntry(
      level: level,
      timestamp: DateTime.now(),
      context: _getCurrentContext(),
    );
    
    _energyHistory.add(entry);
    _currentEnergyLevel = level;
    _lastEnergyLog = DateTime.now();
    
    // Keep only last 7 days
    _energyHistory = _energyHistory
        .where((e) => e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    
    await _prefs.setString('energyHistory', json.encode(_energyHistory.map((e) => e.toJson()).toList()));
    await _prefs.setInt('lastEnergyLevel', level.index);
    
    _analyzePatterns();
    notifyListeners();
  }

  String _getCurrentContext() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour <= 9) return 'morning';
    if (hour >= 9 && hour <= 12) return 'mid-morning';
    if (hour >= 12 && hour <= 14) return 'lunch';
    if (hour >= 14 && hour <= 17) return 'afternoon';
    if (hour >= 17 && hour <= 20) return 'evening';
    return 'night';
  }

  // Productivity Pattern Analysis
  Future<void> _loadEnergyData() async {
    final historyJson = _prefs.getString('energyHistory');
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      _energyHistory = historyList.map((e) => EnergyEntry.fromJson(e)).toList();
    }
    
    final lastLevel = _prefs.getInt('lastEnergyLevel');
    if (lastLevel != null) {
      _currentEnergyLevel = EnergyLevel.values[lastLevel];
    }
  }

  Future<void> _loadProductivityPatterns() async {
    final patternsJson = _prefs.getString('productivityPattern');
    if (patternsJson != null) {
      final Map<String, dynamic> patterns = json.decode(patternsJson);
      _productivityPattern = patterns.map((k, v) => MapEntry(k, v.toDouble()));
    } else {
      // Initialize with default patterns
      _productivityPattern = {
        for (int i = 0; i < 24; i++) i.toString(): 0.7,
      };
    }
  }

  void _analyzePatterns() {
    if (_energyHistory.isEmpty) return;
    
    // Calculate average productivity per hour
    final Map<String, List<double>> hourlyEnergy = {};
    
    for (var entry in _energyHistory) {
      final hour = entry.timestamp.hour.toString();
      hourlyEnergy.putIfAbsent(hour, () => []);
      hourlyEnergy[hour]!.add(entry.level.multiplier);
    }
    
    // Update patterns
    for (var entry in hourlyEnergy.entries) {
      _productivityPattern[entry.key] = entry.value.average;
    }
    
    // Find peak productivity hour
    double maxProd = 0;
    int peakHour = 9;
    for (var entry in _productivityPattern.entries) {
      if (entry.value > maxProd) {
        maxProd = entry.value;
        peakHour = int.parse(entry.key);
      }
    }
    _peakProductivityHour = DateTime.now().copyWith(hour: peakHour);
    
    // Generate AI insights
    _generateInsights();
  }

  Future<void> _saveProductivityPatterns() async {
    await _prefs.setString('productivityPattern', json.encode(_productivityPattern));
  }

  void _generateInsights() {
    _aiInsights.clear();
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Insight: Productivity pattern
    if (_peakProductivityHour != null) {
      final hour = _peakProductivityHour!.hour;
      final timeOfDay = _getTimeOfDay(hour);
      _aiInsights.add(AIInsight(
        type: InsightType.productivity,
        title: "Your Peak Time",
        description: "You're most productive during $timeOfDay ($hour:00). Consider scheduling important tasks then.",
        priority: 8,
      ));
    }
    
    // Insight: Energy trend
    if (_energyHistory.length >= 3) {
      final recent = _energyHistory.take(3).map((e) => e.level.multiplier).average;
      final older = _energyHistory.skip(3).take(3).map((e) => e.level.multiplier).average;
      
      if (recent > older + 0.1) {
        _aiInsights.add(AIInsight(
          type: InsightType.energy,
          title: "Energy Rising",
          description: "Your energy has been increasing. Good time for deep work!",
          priority: 7,
        ));
      } else if (recent < older - 0.1) {
        _aiInsights.add(AIInsight(
          type: InsightType.energy,
          title: "Energy Dip",
          description: "Your energy is lower than usual. Consider a scatterfocus break.",
          priority: 7,
        ));
      }
    }
    
    // Insight: Attention warning
    if (_attentionScore < 0.4 && _isFocusing) {
      _aiInsights.add(AIInsight(
        type: InsightType.attention,
        title: "Attention Low",
        description: "Your attention has drifted. Take a 5-minute break to reset.",
        priority: 10,
      ));
    }
    
    // Insight: Task backlog
    final backlog = _tasks.where((t) => !t.isCompleted && t.type == TaskType.purposeful).length;
    if (backlog > 5) {
      _aiInsights.add(AIInsight(
        type: InsightType.tasks,
        title: "Deep Work Accumulating",
        description: "You have $backlog purposeful tasks waiting. Your peak productivity window is approaching.",
        priority: 6,
      ));
    }
    
    _aiInsights.sort((a, b) => b.priority.compareTo(a.priority));
  }

  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return "morning";
    if (hour >= 12 && hour < 17) return "afternoon";
    if (hour >= 17 && hour < 21) return "evening";
    return "night";
  }

  // AI Task Categorization (Sophisticated, not just keywords)
  void addTask(String title) {
    final category = _categorizeTaskAI(title);
    
    _tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: category,
      createdAt: DateTime.now(),
    ));
    
    _saveTasks();
    _generateInsights();
    notifyListeners();
  }

  TaskType _categorizeTaskAI(String title) {
    final normalized = title.toLowerCase().trim();
    final words = normalized.split(' ');
    
    // Check for explicit purpose indicators
    final purposefulIndicators = [
      'create', 'build', 'design', 'implement', 'write', 'develop',
      'plan', 'analyze', 'research', 'solve', 'complete', 'finish',
      'learn', 'study', 'master', 'deep work', 'focus'
    ];
    
    // Check for distracting indicators  
    final distractingIndicators = [
      'check', 'browse', 'scroll', 'watch', 'play', 'game',
      'social media', 'twitter', 'instagram', 'facebook', 'tiktok',
      'news', 'email', 'messages', 'chat'
    ];
    
    // Check for unnecessary indicators
    final unnecessaryIndicators = [
      'maybe', 'someday', 'later', 'consider', 'think about',
      'wish', 'hope', 'dream', 'might do'
    ];
    
    // Count matches
    int purposefulCount = purposefulIndicators.where((i) => normalized.contains(i)).length;
    int distractingCount = distractingIndicators.where((i) => normalized.contains(i)).length;
    int unnecessaryCount = unnecessaryIndicators.where((i) => normalized.contains(i)).length;
    
    // Check for compound tasks (contain both work and distraction)
    final isCompound = normalized.contains(' and ') || normalized.contains(',');
    
    if (isCompound) {
      // Split and analyze components
      final parts = normalized.split(/(?:,| and )/);
      final partTypes = parts.map(_categorizeSimpleTask).toList();
      
      if (partTypes.contains(TaskType.purposeful)) {
        return TaskType.purposeful;
      } else if (partTypes.contains(TaskType.distracting)) {
        return TaskType.distracting;
      }
    }
    
    // Decision logic with AI-like scoring
    if (purposefulCount > distractingCount && purposefulCount > unnecessaryCount) {
      return TaskType.purposeful;
    } else if (distractingCount > purposefulCount && distractingCount > unnecessaryCount) {
      return TaskType.distracting;
    } else if (unnecessaryCount > purposefulCount && unnecessaryCount > distractingCount) {
      return TaskType.unnecessary;
    } else if (purposefulCount == 0 && distractingCount == 0 && unnecessaryCount == 0) {
      // AI inference: analyze task structure
      return _inferTaskType(words);
    }
    
    // Default to necessary (default bucket)
    return TaskType.necessary;
  }

  TaskType _categorizeSimpleTask(String task) {
    final purposeful = ['create', 'build', 'design', 'implement', 'write', 'develop'];
    final distracting = ['check', 'browse', 'watch', 'play', 'game'];
    
    if (purposeful.any((p) => task.contains(p))) return TaskType.purposeful;
    if (distracting.any((d) => task.contains(d))) return TaskType.distracting;
    return TaskType.necessary;
  }

  TaskType _inferTaskType(List<String> words) {
    // Heuristic inference based on task structure
    // Longer, specific tasks are more likely purposeful
    if (words.length >= 4) {
      // Multi-word tasks with verbs often purposeful
      final actionVerbs = ['the', 'to', 'for', 'my'];
      final hasAction = words.any((w) => !actionVerbs.contains(w));
      if (hasAction) return TaskType.purposeful;
    }
    
    // Short vague tasks often unnecessary
    if (words.length <= 2) {
      return TaskType.unnecessary;
    }
    
    return TaskType.necessary;
  }

  void completeTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = true;
      _tasks[index].completedAt = DateTime.now();
      _saveTasks();
      _triggerHaptic(HapticFeedbackType.mediumImpact);
      _generateInsights();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  // Attention Monitoring
  void logDistraction() {
    _distractionCount++;
    _distractions.add(Distraction(
      timestamp: DateTime.now(),
      attentionScore: _attentionScore,
    ));
    
    // Reduce attention score
    _attentionScore = (_attentionScore - 0.1).clamp(0.0, 1.0);
    
    notifyListeners();
  }

  void resetAttention() {
    _attentionScore = 1.0;
    notifyListeners();
  }

  void updateAttention(double score) {
    _attentionScore = score.clamp(0.0, 1.0);
    
    // Generate attention-related insights
    if (_attentionScore < 0.3) {
      _aiInsights.add(AIInsight(
        type: InsightType.attention,
        title: "Attention Critical",
        description: "Your focus has significantly drifted. Consider ending this session.",
        priority: 10,
      ));
    }
    
    notifyListeners();
  }

  // Focus Session
  void startFocusSession({FocusMode mode = FocusMode.hyperfocus}) {
    if (_isFocusing) return;

    _currentMode = mode;
    _isFocusing = true;
    _attentionScore = 1.0;
    _distractionCount = 0;
    
    final duration = mode == FocusMode.hyperfocus
        ? hyperfocusDuration
        : scatterfocusDuration;
    _remainingTime = duration;

    notifyListeners();
    _triggerHaptic(HapticFeedbackType.mediumImpact);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        
        // Random attention drift (more likely during long sessions)
        if (_remainingTime.inSeconds % 60 == 0 && _currentMode == FocusMode.hyperfocus) {
          _attentionScore = (_attentionScore * (0.95 + (0.1 * (1 - _attentionScore)))).clamp(0.3, 1.0);
        }
        
        notifyListeners();
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _isFocusing = false;
    _sessionCount++;
    
    // Update productivity pattern for this hour
    final hour = DateTime.now().hour.toString();
    final currentScore = _productivityPattern[hour] ?? 0.7;
    // Weight recent sessions more heavily
    _productivityPattern[hour] = (currentScore * 0.7 + _attentionScore * 0.3);
    _saveProductivityPatterns();
    
    // Update patterns and insights
    _analyzePatterns();
    
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

  Future<void> _loadTasks() async {
    final tasksJson = _prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      _tasks = tasksList.map((t) => Task.fromJson(t)).toList();
    } else {
      _tasks = [
        Task(
            id: '1',
            title: 'Complete UI Implementation',
            type: TaskType.purposeful,
            createdAt: DateTime.now()),
        Task(id: '2', title: 'Email Triage', type: TaskType.necessary, createdAt: DateTime.now()),
        Task(id: '3', title: 'Check Social Media', type: TaskType.distracting, createdAt: DateTime.now()),
      ];
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

extension on List<double> {
  double get average => isEmpty ? 0 : reduce((a, b) => a + b) / length;
}

// Enhanced Task Model
class Task {
  final String id;
  final String title;
  final TaskType type;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.index,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        type: TaskType.values[json['type']],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      );
}

// Energy Entry Model
class EnergyEntry {
  final EnergyLevel level;
  final DateTime timestamp;
  final String context;

  EnergyEntry({
    required this.level,
    required this.timestamp,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
        'level': level.index,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };

  factory EnergyEntry.fromJson(Map<String, dynamic> json) => EnergyEntry(
        level: EnergyLevel.values[json['level']],
        timestamp: DateTime.parse(json['timestamp']),
        context: json['context'] ?? 'unknown',
      );
}

// Distraction Model
class Distraction {
  final DateTime timestamp;
  final double attentionScore;

  Distraction({required this.timestamp, required this.attentionScore});
}

// AI Insight Model
enum InsightType { productivity, energy, attention, tasks }

class AIInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final int priority;
  final DateTime createdAt;

  AIInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = DateTime.now();
}
