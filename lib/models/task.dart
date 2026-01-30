enum TaskType { purposeful, necessary, distracting, unnecessary }

class Task {
  final String id;
  final String title;
  final TaskType type;
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
        isCompleted: json['isCompleted'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(), // Fallback for old tasks
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}
