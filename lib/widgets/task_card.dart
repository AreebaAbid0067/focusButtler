import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getCategoryColor() {
    return task.category == TaskCategory.hyperfocus
        ? Colors.deepPurple
        : Colors.teal;
  }

  String _getIntensityLabel() {
    if (task.intensity == null) return '';
    return task.intensity.toString().split('.').last.toUpperCase();
  }

  String _getStatusLabel() {
    return task.status.toString().split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'P${task.priority}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Category and intensity badges
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      task.category == TaskCategory.hyperfocus
                          ? '🔥 Hyperfocus'
                          : '💡 Scatterfocus',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getCategoryColor(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (task.intensity != null)
                    Chip(
                      label: Text(
                        _getIntensityLabel(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  Chip(
                    label: Text(
                      '${task.estimatedMinutes}m',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Footer with status and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (onComplete != null &&
                          task.status != TaskStatus.completed)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: onComplete,
                          iconSize: 20,
                        ),
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                          iconSize: 20,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                          iconSize: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    if (task.priority >= 5) return Colors.red;
    if (task.priority >= 4) return Colors.orange;
    if (task.priority >= 3) return Colors.yellow.shade700;
    return Colors.green;
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.paused:
        return Colors.orange;
      case TaskStatus.pending:
        return Colors.grey;
    }
  }
}
