import '../utils/datetime_utils.dart';

enum TaskCategory { hyperfocus, scatterfocus }
enum HyperfocusIntensity { relaxed, normal, intense }
enum TaskStatus { pending, inProgress, completed, paused }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final HyperfocusIntensity? intensity; // Only for hyperfocus tasks
  final int estimatedMinutes;
  final int priority; // 1-5, where 5 is highest
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? completedAt;
  final List<String> tags;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.intensity,
    required this.estimatedMinutes,
    required this.priority,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    this.scheduledFor,
    this.completedAt,
    this.tags = const [],
  })  : id = id ?? DateTimeUtils.generateId(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    HyperfocusIntensity? intensity,
    int? estimatedMinutes,
    int? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      intensity: intensity ?? this.intensity,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, category: $category, status: $status)';
  }
}
