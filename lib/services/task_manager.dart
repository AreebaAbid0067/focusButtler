import '../models/task.dart';

class TaskManager {
  static const String storageKey = 'tasks';

  /// Creates a new task and automatically categorizes it
  static Future<Task> createTask({
    required String title,
    required String description,
    required int estimatedMinutes,
    required int priority,
    HyperfocusIntensity? manualIntensity,
    List<String> tags = const [],
  }) async {
    // In production, would call AI categorizer here
    // For now, basic logic:
    
    final categoryScore = priority * (estimatedMinutes ~/ 30);
    final category = categoryScore > 75
        ? TaskCategory.hyperfocus
        : TaskCategory.scatterfocus;

    HyperfocusIntensity? intensity;
    if (category == TaskCategory.hyperfocus) {
      intensity = manualIntensity ??
          (priority >= 4
              ? HyperfocusIntensity.intense
              : HyperfocusIntensity.normal);
    }

    return Task(
      title: title,
      description: description,
      category: category,
      intensity: intensity,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      tags: tags,
    );
  }

  /// Completes a task and records completion time
  static Task completeTask(Task task) {
    return task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Pauses a task (for resuming later)
  static Task pauseTask(Task task) {
    return task.copyWith(status: TaskStatus.paused);
  }

  /// Resumes a paused task
  static Task resumeTask(Task task) {
    return task.copyWith(status: TaskStatus.inProgress);
  }

  /// Gets statistics for completed tasks
  static Map<String, dynamic> getTaskStats(List<Task> tasks) {
    final completed = tasks.where((t) => t.status == TaskStatus.completed);
    final pending = tasks.where((t) => t.status == TaskStatus.pending);
    final hyperfocus = tasks.where((t) => t.category == TaskCategory.hyperfocus);
    final scatterfocus =
        tasks.where((t) => t.category == TaskCategory.scatterfocus);

    return {
      'totalTasks': tasks.length,
      'completedTasks': completed.length,
      'pendingTasks': pending.length,
      'hyperfocusTasks': hyperfocus.length,
      'scatterfocusTasks': scatterfocus.length,
      'completionRate': tasks.isEmpty
          ? 0
          : (completed.length / tasks.length * 100).toStringAsFixed(1),
      'totalMinutesCompleted':
          completed.fold(0, (sum, t) => sum + t.estimatedMinutes),
    };
  }

  /// Filters tasks by various criteria
  static List<Task> filterTasks(
    List<Task> tasks, {
    TaskCategory? category,
    TaskStatus? status,
    int? priorityMin,
    int? priorityMax,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return tasks.where((task) {
      if (category != null && task.category != category) return false;
      if (status != null && task.status != status) return false;
      if (priorityMin != null && task.priority < priorityMin) return false;
      if (priorityMax != null && task.priority > priorityMax) return false;
      if (dateFrom != null && task.createdAt.isBefore(dateFrom)) return false;
      if (dateTo != null && task.createdAt.isAfter(dateTo)) return false;
      return true;
    }).toList();
  }

  /// Sorts tasks by priority and due date
  static List<Task> prioritizeTasks(List<Task> tasks) {
    final sortedTasks = [...tasks];
    sortedTasks.sort((a, b) {
      // First by status (pending first)
      if (a.status != b.status) {
        return a.status.index.compareTo(b.status.index);
      }
      // Then by priority (higher first)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      // Then by scheduled time
      if (a.scheduledFor != null && b.scheduledFor != null) {
        return a.scheduledFor!.compareTo(b.scheduledFor!);
      }
      return 0;
    });
    return sortedTasks;
  }
}
