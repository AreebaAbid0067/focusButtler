import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_manager.dart';
import '../widgets/task_card.dart';
import '../widgets/energy_tracker_widget.dart' as et_widget;
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  int _currentEnergy = 50;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load sample tasks
    setState(() {
      _tasks = [
        Task(
          title: 'Debug login feature',
          description: 'Fix authentication issue in mobile app',
          category: TaskCategory.hyperfocus,
          intensity: HyperfocusIntensity.intense,
          estimatedMinutes: 120,
          priority: 5,
          status: TaskStatus.pending,
        ),
        Task(
          title: 'Brainstorm new features',
          description: 'Design session for Q2 roadmap',
          category: TaskCategory.scatterfocus,
          estimatedMinutes: 60,
          priority: 3,
          status: TaskStatus.pending,
        ),
        Task(
          title: 'Code review PRs',
          description: 'Review team members pull requests',
          category: TaskCategory.hyperfocus,
          intensity: HyperfocusIntensity.normal,
          estimatedMinutes: 90,
          priority: 4,
          status: TaskStatus.pending,
        ),
      ];
    });
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    ).then((newTask) {
      if (newTask != null && newTask is Task) {
        setState(() {
          _tasks.add(newTask);
        });
      }
    });
  }

  void _completeTask(Task task) {
    setState(() {
      final index = _tasks.indexOf(task);
      if (index != -1) {
        _tasks[index] = TaskManager.completeTask(task);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task completed! 🎉')),
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void _recordEnergy(int energy) {
    setState(() {
      _currentEnergy = energy;
    });
  }

  Widget _buildHomeTab() {
    final stats = TaskManager.getTaskStats(_tasks);
    final pendingTasks =
        TaskManager.filterTasks(_tasks, status: TaskStatus.pending);
    final prioritizedTasks = TaskManager.prioritizeTasks(pendingTasks);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome banner with energy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Energy: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _currentEnergy / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _currentEnergy > 70
                              ? Colors.lightGreen
                              : _currentEnergy > 40
                                  ? Colors.yellow
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_currentEnergy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Tasks',
                  '${stats['totalTasks']}',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Completed',
                  '${stats['completedTasks']}',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Pending',
                  '${stats['pendingTasks']}',
                  Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tasks section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (prioritizedTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.done_all, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No pending tasks!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up. Create a new task or relax! 🎉',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prioritizedTasks.length,
              itemBuilder: (context, index) {
                final task = prioritizedTasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    // TODO: Navigate to task detail
                  },
                  onComplete: () => _completeTask(task),
                  onDelete: () => _deleteTask(task),
                );
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEnergyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          et_widget.EnergyTrackerWidget(onEnergyRecorded: _recordEnergy),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Energy tracking is active.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final stats = TaskManager.getTaskStats(_tasks);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Total Tasks',
                      '${stats['totalTasks']}',
                    ),
                    _buildStatRow(
                      'Completed Tasks',
                      '${stats['completedTasks']}',
                    ),
                    _buildStatRow(
                      'Completion Rate',
                      '${stats['completionRate']}%',
                    ),
                    _buildStatRow(
                      'Hyperfocus Tasks',
                      '${stats['hyperfocusTasks']}',
                    ),
                    _buildStatRow(
                      'Scatterfocus Tasks',
                      '${stats['scatterfocusTasks']}',
                    ),
                    _buildStatRow(
                      'Minutes Completed',
                      '${stats['totalMinutesCompleted']} min',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterButtler'),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildEnergyTab(),
          _buildAnalyticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.energy_savings_leaf),
            label: 'Energy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addTask,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
