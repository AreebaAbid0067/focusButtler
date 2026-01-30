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
import 'task_type.dart' as _i2;

/// A task in the Hyperfocus productivity system
abstract class Task implements _i1.SerializableModel {
  Task._({
    required this.id,
    required this.title,
    required this.type,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.aiRecommendedTime,
  });

  factory Task({
    required String id,
    required String title,
    required _i2.TaskType type,
    required bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
    DateTime? aiRecommendedTime,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      type: _i2.TaskType.fromJson((jsonSerialization['type'] as String)),
      isCompleted: jsonSerialization['isCompleted'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      aiRecommendedTime: jsonSerialization['aiRecommendedTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['aiRecommendedTime'],
            ),
    );
  }

  /// Unique identifier
  String id;

  /// Title of the task
  String title;

  /// Type classification (purposeful, necessary, distracting, unnecessary)
  _i2.TaskType type;

  /// Whether the task has been completed
  bool isCompleted;

  /// When the task was created
  DateTime createdAt;

  /// When the task was completed (null if not completed)
  DateTime? completedAt;

  /// AI-recommended optimal time to work on this task
  DateTime? aiRecommendedTime;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    String? id,
    String? title,
    _i2.TaskType? type,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? aiRecommendedTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      'id': id,
      'title': title,
      'type': type.toJson(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (aiRecommendedTime != null)
        'aiRecommendedTime': aiRecommendedTime?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    required String id,
    required String title,
    required _i2.TaskType type,
    required bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
    DateTime? aiRecommendedTime,
  }) : super._(
         id: id,
         title: title,
         type: type,
         isCompleted: isCompleted,
         createdAt: createdAt,
         completedAt: completedAt,
         aiRecommendedTime: aiRecommendedTime,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    String? id,
    String? title,
    _i2.TaskType? type,
    bool? isCompleted,
    DateTime? createdAt,
    Object? completedAt = _Undefined,
    Object? aiRecommendedTime = _Undefined,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      aiRecommendedTime: aiRecommendedTime is DateTime?
          ? aiRecommendedTime
          : this.aiRecommendedTime,
    );
  }
}
