class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetValue;
  final AchievementCategory category;

  bool isUnlocked;
  int currentValue;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.category,
    this.isUnlocked = false,
    this.currentValue = 0,
    this.unlockedAt,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
        'currentValue': currentValue,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: achievements
          .firstWhere((a) => a.id == json['id'])
          .title,
      description: achievements
          .firstWhere((a) => a.id == json['id'])
          .description,
      icon: achievements
          .firstWhere((a) => a.id == json['id'])
          .icon,
      targetValue: achievements
          .firstWhere((a) => a.id == json['id'])
          .targetValue,
      category: achievements
          .firstWhere((a) => a.id == json['id'])
          .category,
      isUnlocked: json['isUnlocked'] ?? false,
      currentValue: json['currentValue'] ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
}

enum AchievementCategory {
  streaks,
  focus,
  tasks,
  milestones,
}

List<Achievement> getDefaultAchievements() {
  return [
    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: 'Complete 3 focus sessions',
      icon: 'local_fire_department',
      targetValue: 3,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day focus streak',
      icon: 'emoji_events',
      targetValue: 7,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Maintain a 30-day focus streak',
      icon: 'military_tech',
      targetValue: 30,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Century Club',
      description: 'Maintain a 100-day focus streak',
      icon: 'workspace_premium',
      targetValue: 100,
      category: AchievementCategory.streaks,
    ),
    // Focus achievements
    Achievement(
      id: 'focus_hours_1',
      title: 'First Hour',
      description: 'Complete 1 hour of focused work',
      icon: 'schedule',
      targetValue: 60,
      category: AchievementCategory.focus,
    ),
    Achievement(
      id: 'focus_hours_10',
      title: 'Dedicated',
      description: 'Complete 10 hours of focused work',
      icon: 'timelapse',
      targetValue: 600,
      category: AchievementCategory.focus,
    ),
    Achievement(
      id: 'focus_hours_50',
      title: 'Focus Champion',
      description: 'Complete 50 hours of focused work',
      icon: 'stars',
      targetValue: 3000,
      category: AchievementCategory.focus,
    ),
    // Task achievements
    Achievement(
      id: 'tasks_10',
      title: 'Task Tackler',
      description: 'Complete 10 purposeful tasks',
      icon: 'task_alt',
      targetValue: 10,
      category: AchievementCategory.tasks,
    ),
    Achievement(
      id: 'tasks_50',
      title: 'Productivity Pro',
      description: 'Complete 50 purposeful tasks',
      icon: 'verified',
      targetValue: 50,
      category: AchievementCategory.tasks,
    ),
    Achievement(
      id: 'tasks_100',
      title: 'Task Titan',
      description: 'Complete 100 purposeful tasks',
      icon: 'diamond',
      targetValue: 100,
      category: AchievementCategory.tasks,
    ),
    // Milestone achievements
    Achievement(
      id: 'first_session',
      title: 'First Steps',
      description: 'Complete your first focus session',
      icon: 'play_arrow',
      targetValue: 1,
      category: AchievementCategory.milestones,
    ),
    Achievement(
      id: 'sessions_25',
      title: 'Consistency King',
      description: 'Complete 25 focus sessions',
      icon: 'crown',
      targetValue: 25,
      category: AchievementCategory.milestones,
    ),
    Achievement(
      id: 'sessions_100',
      title: 'Focus Legend',
      description: 'Complete 100 focus sessions',
      icon: 'auto_awesome',
      targetValue: 100,
      category: AchievementCategory.milestones,
    ),
  ];
}

List<Achievement> achievements = getDefaultAchievements();
