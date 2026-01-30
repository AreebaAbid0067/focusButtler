import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:uuid/uuid.dart';

/// In-memory storage for tasks (mini version without DB)
final _tasks = <String, Task>{};
final _uuid = Uuid();

/// Endpoint for managing tasks in the Hyperfocus system
class TaskEndpoint extends Endpoint {
  /// Get all tasks
  Future<List<Task>> getAll(Session session) async {
    final tasks = _tasks.values.toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  /// Get incomplete tasks only
  Future<List<Task>> getIncomplete(Session session) async {
    final tasks = _tasks.values.where((t) => !t.isCompleted).toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  /// Create a new task
  Future<Task> create(Session session, String title, TaskType type) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      type: type,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _tasks[task.id] = task;
    return task;
  }

  /// Mark a task as completed
  Future<Task?> complete(Session session, String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return null;

    final updated = Task(
      id: task.id,
      title: task.title,
      type: task.type,
      isCompleted: true,
      createdAt: task.createdAt,
      completedAt: DateTime.now(),
      aiRecommendedTime: task.aiRecommendedTime,
    );
    _tasks[taskId] = updated;
    return updated;
  }

  /// Mark a task as incomplete (undo complete)
  Future<Task?> uncomplete(Session session, String taskId) async {
    final task = _tasks[taskId];
    if (task == null) return null;

    final updated = Task(
      id: task.id,
      title: task.title,
      type: task.type,
      isCompleted: false,
      createdAt: task.createdAt,
      completedAt: null,
      aiRecommendedTime: task.aiRecommendedTime,
    );
    _tasks[taskId] = updated;
    return updated;
  }

  /// Delete a task
  Future<bool> delete(Session session, String taskId) async {
    return _tasks.remove(taskId) != null;
  }

  /// Update the AI-recommended time for a task
  Future<Task?> setRecommendedTime(
    Session session,
    String taskId,
    DateTime recommendedTime,
  ) async {
    final task = _tasks[taskId];
    if (task == null) return null;

    final updated = Task(
      id: task.id,
      title: task.title,
      type: task.type,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      aiRecommendedTime: recommendedTime,
    );
    _tasks[taskId] = updated;
    return updated;
  }
}
