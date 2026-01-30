import 'dart:async';
import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import 'package:uuid/uuid.dart';

/// In-memory storage for AI insights (mini version without DB)
final _insights = <String, AIInsight>{};
final _uuid = Uuid();

/// Endpoint for proxying AI agent requests to Agno AgentOS
class AgentEndpoint extends Endpoint {
  // URL of the Agno AgentOS server
  static const String _agnoUrl = 'http://localhost:7777';

  /// Get AI task categorization from the agent
  Future<TaskType> categorizeTask(Session session, String taskTitle) async {
    try {
      final response = await http.post(
        Uri.parse('$_agnoUrl/v1/agents/task_categorizer/runs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': 'Categorize this task: $taskTitle',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final category = data['content']?.toString().toLowerCase() ?? '';

        if (category.contains('purposeful')) return TaskType.purposeful;
        if (category.contains('necessary')) return TaskType.necessary;
        if (category.contains('distracting')) return TaskType.distracting;
        return TaskType.unnecessary;
      }
    } catch (e) {
      session.log('Agent categorization failed: $e');
    }

    // Fallback to purposeful if agent unavailable
    return TaskType.purposeful;
  }

  /// Get productivity coaching insight from the agent
  Future<AIInsight> getCoachingInsight(
    Session session,
    String context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_agnoUrl/v1/agents/productivity_coach/runs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': context,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message =
            data['content']?.toString() ??
            'Stay focused on your purposeful work!';

        final insight = AIInsight(
          id: _uuid.v4(),
          message: message,
          category: 'suggestion',
          generatedAt: DateTime.now(),
          isDismissed: false,
        );
        _insights[insight.id] = insight;
        return insight;
      }
    } catch (e) {
      session.log('Agent coaching failed: $e');
    }

    // Fallback insight
    final fallback = AIInsight(
      id: _uuid.v4(),
      message: 'Keep up the great work! Focus on your most purposeful task.',
      category: 'encouragement',
      generatedAt: DateTime.now(),
      isDismissed: false,
    );
    _insights[fallback.id] = fallback;
    return fallback;
  }

  /// Stream real-time insights during a focus session
  Stream<AIInsight> streamSessionInsights(
    Session session,
    String focusSessionId,
    FocusMode mode,
    int targetMinutes,
  ) async* {
    // Initial encouragement
    yield AIInsight(
      id: _uuid.v4(),
      message: mode == FocusMode.hyperfocus
          ? 'Entering Hyperfocus mode. Clear your mind and concentrate.'
          : 'Entering Scatterfocus mode. Let your mind wander creatively.',
      category: 'encouragement',
      generatedAt: DateTime.now(),
      isDismissed: false,
    );

    // Periodic check-ins (every 10 minutes)
    final checkInInterval = const Duration(minutes: 10);
    int checkInCount = 0;
    final maxCheckIns = targetMinutes ~/ 10;

    while (checkInCount < maxCheckIns) {
      await Future.delayed(checkInInterval);
      checkInCount++;

      final minutesRemaining = targetMinutes - (checkInCount * 10);

      yield AIInsight(
        id: _uuid.v4(),
        message: minutesRemaining > 0
            ? 'You have $minutesRemaining minutes remaining. Stay focused!'
            : 'Great job! Your session is complete.',
        category: 'encouragement',
        generatedAt: DateTime.now(),
        isDismissed: false,
      );
    }
  }

  /// Get all active insights for the user
  Future<List<AIInsight>> getActiveInsights(Session session) async {
    final insights = _insights.values.where((i) => !i.isDismissed).toList();
    insights.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return insights.take(10).toList();
  }

  /// Dismiss an insight
  Future<bool> dismissInsight(Session session, String insightId) async {
    final insight = _insights[insightId];
    if (insight == null) return false;

    final updated = AIInsight(
      id: insight.id,
      message: insight.message,
      category: insight.category,
      generatedAt: insight.generatedAt,
      isDismissed: true,
    );
    _insights[insightId] = updated;
    return true;
  }
}
