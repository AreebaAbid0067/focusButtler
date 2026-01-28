import '../models/task.dart';

class AITaskCategorizer {
  /// Categorizes a task based on its title, description, and priority
  /// Returns TaskCategory (hyperfocus or scatterfocus) and HyperfocusIntensity if applicable
  static Future<(TaskCategory, HyperfocusIntensity?)> categorizeTask(
    String title,
    String description,
    int priority,
  ) async {
    // Simulate AI analysis - In production, this would call an actual AI service
    await Future.delayed(const Duration(milliseconds: 500));

    // Keywords that suggest hyperfocus tasks
    const hyperfocusKeywords = [
      'code',
      'build',
      'develop',
      'design',
      'analyze',
      'complex',
      'difficult',
      'deadline',
      'project',
      'implement',
      'debug',
    ];

    // Keywords that suggest scatterfocus tasks
    const scatterfocusKeywords = [
      'brainstorm',
      'idea',
      'creative',
      'plan',
      'research',
      'explore',
      'think',
      'strategy',
      'discuss',
      'review',
    ];

    final lowerTitle = title.toLowerCase();
    final lowerDescription = description.toLowerCase();
    final combinedText = '$lowerTitle $lowerDescription';

    // Count keyword matches
    int hyperfocusScore = 0;
    int scatterfocusScore = 0;

    for (var keyword in hyperfocusKeywords) {
      if (combinedText.contains(keyword)) hyperfocusScore++;
    }

    for (var keyword in scatterfocusKeywords) {
      if (combinedText.contains(keyword)) scatterfocusScore++;
    }

    // Factor in priority
    hyperfocusScore += (priority ~/ 2);

    // Determine category
    TaskCategory category = hyperfocusScore >= scatterfocusScore
        ? TaskCategory.hyperfocus
        : TaskCategory.scatterfocus;

    // Determine intensity if hyperfocus
    HyperfocusIntensity? intensity;
    if (category == TaskCategory.hyperfocus) {
      if (priority >= 5) {
        intensity = HyperfocusIntensity.intense;
      } else if (priority >= 3) {
        intensity = HyperfocusIntensity.normal;
      } else {
        intensity = HyperfocusIntensity.relaxed;
      }
    }

    return (category, intensity);
  }

  /// Suggests estimated time based on task description
  static Future<int> estimateTaskDuration(
    String title,
    String description,
    TaskCategory category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Base duration by category
    int baseDuration = category == TaskCategory.hyperfocus ? 120 : 45;

    // Adjust based on keywords
    final combinedText = '$title $description'.toLowerCase();

    if (combinedText.contains('quick') || combinedText.contains('simple')) {
      baseDuration = (baseDuration * 0.5).toInt();
    } else if (combinedText.contains('complex') ||
        combinedText.contains('difficult')) {
      baseDuration = (baseDuration * 1.5).toInt();
    }

    return baseDuration;
  }
}
