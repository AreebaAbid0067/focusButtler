import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:uuid/uuid.dart';

/// In-memory storage for focus sessions (mini version without DB)
final _focusSessions = <String, FocusSession>{};
final _uuid = Uuid();

/// Endpoint for managing focus sessions
class SessionEndpoint extends Endpoint {
  /// Start a new focus session
  Future<FocusSession> startSession(
    Session session,
    FocusMode mode,
    int targetMinutes, {
    String? taskId,
  }) async {
    final focusSession = FocusSession(
      id: _uuid.v4(),
      mode: mode,
      startTime: DateTime.now(),
      targetDurationMinutes: targetMinutes,
      wasCompleted: false,
      distractionCount: 0,
      taskId: taskId,
    );
    _focusSessions[focusSession.id] = focusSession;
    return focusSession;
  }

  /// End a focus session
  Future<FocusSession?> endSession(
    Session session,
    String sessionId, {
    bool wasCompleted = true,
  }) async {
    final focusSession = _focusSessions[sessionId];
    if (focusSession == null) return null;

    final updated = FocusSession(
      id: focusSession.id,
      mode: focusSession.mode,
      startTime: focusSession.startTime,
      endTime: DateTime.now(),
      targetDurationMinutes: focusSession.targetDurationMinutes,
      wasCompleted: wasCompleted,
      distractionCount: focusSession.distractionCount,
      taskId: focusSession.taskId,
    );
    _focusSessions[sessionId] = updated;
    return updated;
  }

  /// Log a distraction during a session
  Future<FocusSession?> logDistraction(
    Session session,
    String sessionId,
  ) async {
    final focusSession = _focusSessions[sessionId];
    if (focusSession == null) return null;

    final updated = FocusSession(
      id: focusSession.id,
      mode: focusSession.mode,
      startTime: focusSession.startTime,
      endTime: focusSession.endTime,
      targetDurationMinutes: focusSession.targetDurationMinutes,
      wasCompleted: focusSession.wasCompleted,
      distractionCount: focusSession.distractionCount + 1,
      taskId: focusSession.taskId,
    );
    _focusSessions[sessionId] = updated;
    return updated;
  }

  /// Get today's sessions
  Future<List<FocusSession>> getToday(Session session) async {
    final todayStart = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final sessions = _focusSessions.values
        .where((s) => s.startTime.isAfter(todayStart))
        .toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Get session statistics for the past week
  Future<Map<String, dynamic>> getWeeklyStats(Session session) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final sessions = _focusSessions.values
        .where((s) => s.startTime.isAfter(weekAgo))
        .toList();

    int totalMinutes = 0;
    int completedCount = 0;
    int hyperfocusMinutes = 0;
    int scatterfocusMinutes = 0;
    int totalDistractions = 0;

    for (final s in sessions) {
      if (s.endTime != null) {
        final duration = s.endTime!.difference(s.startTime).inMinutes;
        totalMinutes += duration;
        if (s.mode == FocusMode.hyperfocus) {
          hyperfocusMinutes += duration;
        } else {
          scatterfocusMinutes += duration;
        }
      }
      if (s.wasCompleted) completedCount++;
      totalDistractions += s.distractionCount;
    }

    return {
      'totalSessions': sessions.length,
      'completedSessions': completedCount,
      'totalMinutes': totalMinutes,
      'hyperfocusMinutes': hyperfocusMinutes,
      'scatterfocusMinutes': scatterfocusMinutes,
      'totalDistractions': totalDistractions,
      'averageDistractions': sessions.isEmpty
          ? 0.0
          : totalDistractions / sessions.length,
    };
  }
}
