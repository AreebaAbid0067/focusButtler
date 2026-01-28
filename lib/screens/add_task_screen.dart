import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/ai_task_categorizer.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? editingTask;

  const AddTaskScreen({Key? key, this.editingTask}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedMinutesController;

  int _priority = 3;
  TaskCategory? _selectedCategory;
  HyperfocusIntensity? _selectedIntensity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.editingTask?.description ?? '');
    _estimatedMinutesController = TextEditingController(
      text: widget.editingTask?.estimatedMinutes.toString() ?? '60',
    );
    _priority = widget.editingTask?.priority ?? 3;
    _selectedCategory = widget.editingTask?.category;
    _selectedIntensity = widget.editingTask?.intensity;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _aiCategorizeTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final (category, intensity) =
          await AITaskCategorizer.categorizeTask(
        _titleController.text,
        _descriptionController.text,
        _priority,
      );

      setState(() {
        _selectedCategory = category;
        _selectedIntensity = intensity;
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Auto-categorized as ${category == TaskCategory.hyperfocus ? "Hyperfocus" : "Scatterfocus"}',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _submitTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category or use AI to categorize')),
      );
      return;
    }

    final estimatedMinutes = int.tryParse(_estimatedMinutesController.text) ?? 60;

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory!,
      intensity: _selectedIntensity,
      estimatedMinutes: estimatedMinutes,
      priority: _priority,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'e.g., Fix login bug',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Add more details about the task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            // Estimated Minutes
            TextField(
              controller: _estimatedMinutesController,
              decoration: InputDecoration(
                labelText: 'Estimated Duration (minutes)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Priority
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Priority Level', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: 'P$_priority',
                  onChanged: (value) {
                    setState(() {
                      _priority = value.toInt();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Low'),
                    Text('High'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // AI Categorize Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _aiCategorizeTask,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Analyzing...' : 'AI Categorize'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category selection
            if (_selectedCategory != null) ...[
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<TaskCategory>(
                              segments: const [
                                ButtonSegment(
                                  value: TaskCategory.hyperfocus,
                                  label: Text('🔥 Hyperfocus'),
                                ),
                                ButtonSegment(
                                  value: TaskCategory.scatterfocus,
                                  label: Text('💡 Scatterfocus'),
                                ),
                              ],
                              selected: {_selectedCategory!},
                              onSelectionChanged: (Set<TaskCategory> newSelection) {
                                setState(() {
                                  _selectedCategory = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory == TaskCategory.hyperfocus) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Hyperfocus Intensity',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: HyperfocusIntensity.values
                              .map((intensity) {
                            return FilterChip(
                              label: Text(intensity.toString().split('.').last),
                              selected: _selectedIntensity == intensity,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedIntensity =
                                      selected ? intensity : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  widget.editingTask == null ? 'Create Task' : 'Update Task',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
