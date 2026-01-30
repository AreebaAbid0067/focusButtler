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
import 'ai_insight.dart' as _i2;
import 'energy_entry.dart' as _i3;
import 'energy_level.dart' as _i4;
import 'focus_mode.dart' as _i5;
import 'focus_session.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'task.dart' as _i8;
import 'task_type.dart' as _i9;
import 'package:hyperfocus_server_client/src/protocol/ai_insight.dart' as _i10;
import 'package:hyperfocus_server_client/src/protocol/energy_entry.dart'
    as _i11;
import 'package:hyperfocus_server_client/src/protocol/energy_level.dart'
    as _i12;
import 'package:hyperfocus_server_client/src/protocol/focus_session.dart'
    as _i13;
import 'package:hyperfocus_server_client/src/protocol/task.dart' as _i14;
export 'ai_insight.dart';
export 'energy_entry.dart';
export 'energy_level.dart';
export 'focus_mode.dart';
export 'focus_session.dart';
export 'greetings/greeting.dart';
export 'task.dart';
export 'task_type.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AIInsight) {
      return _i2.AIInsight.fromJson(data) as T;
    }
    if (t == _i3.EnergyEntry) {
      return _i3.EnergyEntry.fromJson(data) as T;
    }
    if (t == _i4.EnergyLevel) {
      return _i4.EnergyLevel.fromJson(data) as T;
    }
    if (t == _i5.FocusMode) {
      return _i5.FocusMode.fromJson(data) as T;
    }
    if (t == _i6.FocusSession) {
      return _i6.FocusSession.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.Task) {
      return _i8.Task.fromJson(data) as T;
    }
    if (t == _i9.TaskType) {
      return _i9.TaskType.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AIInsight?>()) {
      return (data != null ? _i2.AIInsight.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.EnergyEntry?>()) {
      return (data != null ? _i3.EnergyEntry.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.EnergyLevel?>()) {
      return (data != null ? _i4.EnergyLevel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.FocusMode?>()) {
      return (data != null ? _i5.FocusMode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FocusSession?>()) {
      return (data != null ? _i6.FocusSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Task?>()) {
      return (data != null ? _i8.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.TaskType?>()) {
      return (data != null ? _i9.TaskType.fromJson(data) : null) as T;
    }
    if (t == List<_i10.AIInsight>) {
      return (data as List).map((e) => deserialize<_i10.AIInsight>(e)).toList()
          as T;
    }
    if (t == List<_i11.EnergyEntry>) {
      return (data as List)
              .map((e) => deserialize<_i11.EnergyEntry>(e))
              .toList()
          as T;
    }
    if (t == Map<int, _i12.EnergyLevel>) {
      return Map.fromEntries(
            (data as List).map(
              (e) => MapEntry(
                deserialize<int>(e['k']),
                deserialize<_i12.EnergyLevel>(e['v']),
              ),
            ),
          )
          as T;
    }
    if (t == List<_i13.FocusSession>) {
      return (data as List)
              .map((e) => deserialize<_i13.FocusSession>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == List<_i14.Task>) {
      return (data as List).map((e) => deserialize<_i14.Task>(e)).toList() as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AIInsight => 'AIInsight',
      _i3.EnergyEntry => 'EnergyEntry',
      _i4.EnergyLevel => 'EnergyLevel',
      _i5.FocusMode => 'FocusMode',
      _i6.FocusSession => 'FocusSession',
      _i7.Greeting => 'Greeting',
      _i8.Task => 'Task',
      _i9.TaskType => 'TaskType',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'hyperfocus_server.',
        '',
      );
    }

    switch (data) {
      case _i2.AIInsight():
        return 'AIInsight';
      case _i3.EnergyEntry():
        return 'EnergyEntry';
      case _i4.EnergyLevel():
        return 'EnergyLevel';
      case _i5.FocusMode():
        return 'FocusMode';
      case _i6.FocusSession():
        return 'FocusSession';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.Task():
        return 'Task';
      case _i9.TaskType():
        return 'TaskType';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AIInsight') {
      return deserialize<_i2.AIInsight>(data['data']);
    }
    if (dataClassName == 'EnergyEntry') {
      return deserialize<_i3.EnergyEntry>(data['data']);
    }
    if (dataClassName == 'EnergyLevel') {
      return deserialize<_i4.EnergyLevel>(data['data']);
    }
    if (dataClassName == 'FocusMode') {
      return deserialize<_i5.FocusMode>(data['data']);
    }
    if (dataClassName == 'FocusSession') {
      return deserialize<_i6.FocusSession>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i8.Task>(data['data']);
    }
    if (dataClassName == 'TaskType') {
      return deserialize<_i9.TaskType>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}
