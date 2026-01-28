import '../models/task.dart';
import '../models/energy_level.dart';

class SmartScheduler {
  /// Analyzes energy patterns and suggests the best time for a task
  static Future<DateTime?> suggestBestTimeForTask(
    Task task,
    List<DailyEnergyPattern> energyHistory,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (energyHistory.isEmpty) {
      return null;
    }

    // Get average energy pattern across all days
    final averageByHour = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      double totalEnergy = 0;
      int count = 0;
      for (var dayPattern in energyHistory) {
        final hourEntries = dayPattern.getEntriesByHour(hour);
        if (hourEntries.isNotEmpty) {
          for (var entry in hourEntries) {
            totalEnergy += entry.level;
            count++;
          }
        }
      }
      if (count > 0) {
        averageByHour[hour] = totalEnergy / count;
      }
    }

    // Find best time based on task category
    int bestHour = 9; // Default to 9 AM

    if (task.category == TaskCategory.hyperfocus) {
      // Find peak energy hour for hyperfocus
      double maxEnergy = 0;
      averageByHour.forEach((hour, energy) {
        if (energy > maxEnergy && hour >= 6 && hour <= 18) {
          maxEnergy = energy;
          bestHour = hour;
        }
      });
    } else {
      // Find a moderate energy hour for scatterfocus (not peak, not low)
      double targetEnergy = 60; // Moderate energy
      int closestHour = 14;
      double closestDiff = double.infinity;

      averageByHour.forEach((hour, energy) {
        if (hour >= 6 && hour <= 20) {
          double diff = (energy - targetEnergy).abs();
          if (diff < closestDiff) {
            closestDiff = diff;
            closestHour = hour;
          }
        }
      });
      bestHour = closestHour;
    }

    // Create scheduled time for today or next day
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, bestHour, 0);

    // If the time has passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Checks if scheduling a task at a given time would overload the user
  static bool wouldExceedDailyLimit(
    DateTime scheduledTime,
    int taskDuration,
    List<Task> existingTasks,
    int dailyLimitMinutes,
  ) {
    final dayTasks = existingTasks.where((task) {
      return task.scheduledFor != null &&
          task.scheduledFor!.year == scheduledTime.year &&
          task.scheduledFor!.month == scheduledTime.month &&
          task.scheduledFor!.day == scheduledTime.day &&
          task.status != TaskStatus.completed;
    }).toList();

    int totalMinutes =
        dayTasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
    totalMinutes += taskDuration;

    return totalMinutes > dailyLimitMinutes;
  }

  /// Prevents time-wasting by flagging unproductive behavior
  static Future<bool> isUnproductiveBehavior(
    Task task,
    List<Task> completedTasks,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if user is spending too much time on low-priority scatterfocus tasks
    final recentScatterfocus = completedTasks
        .where((t) =>
            t.category == TaskCategory.scatterfocus &&
            t.priority <= 2 &&
            DateTime.now().difference(t.completedAt ?? DateTime.now()).inHours <
                4)
        .toList();

    if (recentScatterfocus.length >= 3) {
      return true; // Potential time-wasting behavior
    }

    return false;
  }
}
