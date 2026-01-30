enum TaskType { purposeful, necessary, distracting, unnecessary }

class Task {
  final String id;
  final String title;
  final TaskType type;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
  });

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
