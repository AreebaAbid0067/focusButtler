import '../utils/datetime_utils.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;
  final bool notificationsEnabled;
  final int dailyGoalMinutes;

  UserProfile({
    String? id,
    required this.name,
    required this.email,
    DateTime? createdAt,
    this.preferences = const {},
    this.notificationsEnabled = true,
    this.dailyGoalMinutes = 480, // 8 hours default
  })  : id = id ?? DateTimeUtils.generateId(),
        createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
    bool? notificationsEnabled,
    int? dailyGoalMinutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email)';
  }
}
