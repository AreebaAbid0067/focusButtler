/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'focus_mode.dart' as _i2;

/// A focus session record
abstract class FocusSession implements _i1.SerializableModel {
  FocusSession._({
    required this.id,
    required this.mode,
    required this.startTime,
    this.endTime,
    required this.targetDurationMinutes,
    required this.wasCompleted,
    required this.distractionCount,
    this.taskId,
  });

  factory FocusSession({
    required String id,
    required _i2.FocusMode mode,
    required DateTime startTime,
    DateTime? endTime,
    required int targetDurationMinutes,
    required bool wasCompleted,
    required int distractionCount,
    String? taskId,
  }) = _FocusSessionImpl;

  factory FocusSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return FocusSession(
      id: jsonSerialization['id'] as String,
      mode: _i2.FocusMode.fromJson((jsonSerialization['mode'] as String)),
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      targetDurationMinutes: jsonSerialization['targetDurationMinutes'] as int,
      wasCompleted: jsonSerialization['wasCompleted'] as bool,
      distractionCount: jsonSerialization['distractionCount'] as int,
      taskId: jsonSerialization['taskId'] as String?,
    );
  }

  /// Unique identifier
  String id;

  /// The focus mode used in this session
  _i2.FocusMode mode;

  /// When the session started
  DateTime startTime;

  /// When the session ended (null if ongoing)
  DateTime? endTime;

  /// Target duration in minutes
  int targetDurationMinutes;

  /// Whether the session was completed successfully
  bool wasCompleted;

  /// Number of distractions logged during session
  int distractionCount;

  /// Task being worked on (optional)
  String? taskId;

  /// Returns a shallow copy of this [FocusSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FocusSession copyWith({
    String? id,
    _i2.FocusMode? mode,
    DateTime? startTime,
    DateTime? endTime,
    int? targetDurationMinutes,
    bool? wasCompleted,
    int? distractionCount,
    String? taskId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FocusSession',
      'id': id,
      'mode': mode.toJson(),
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'targetDurationMinutes': targetDurationMinutes,
      'wasCompleted': wasCompleted,
      'distractionCount': distractionCount,
      if (taskId != null) 'taskId': taskId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FocusSessionImpl extends FocusSession {
  _FocusSessionImpl({
    required String id,
    required _i2.FocusMode mode,
    required DateTime startTime,
    DateTime? endTime,
    required int targetDurationMinutes,
    required bool wasCompleted,
    required int distractionCount,
    String? taskId,
  }) : super._(
         id: id,
         mode: mode,
         startTime: startTime,
         endTime: endTime,
         targetDurationMinutes: targetDurationMinutes,
         wasCompleted: wasCompleted,
         distractionCount: distractionCount,
         taskId: taskId,
       );

  /// Returns a shallow copy of this [FocusSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FocusSession copyWith({
    String? id,
    _i2.FocusMode? mode,
    DateTime? startTime,
    Object? endTime = _Undefined,
    int? targetDurationMinutes,
    bool? wasCompleted,
    int? distractionCount,
    Object? taskId = _Undefined,
  }) {
    return FocusSession(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime is DateTime? ? endTime : this.endTime,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      distractionCount: distractionCount ?? this.distractionCount,
      taskId: taskId is String? ? taskId : this.taskId,
    );
  }
}
