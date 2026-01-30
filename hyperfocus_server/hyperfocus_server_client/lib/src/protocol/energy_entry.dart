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
import 'energy_level.dart' as _i2;

/// An energy entry logged by the user
abstract class EnergyEntry implements _i1.SerializableModel {
  EnergyEntry._({
    required this.id,
    required this.level,
    required this.timestamp,
    required this.hourOfDay,
  });

  factory EnergyEntry({
    required String id,
    required _i2.EnergyLevel level,
    required DateTime timestamp,
    required int hourOfDay,
  }) = _EnergyEntryImpl;

  factory EnergyEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnergyEntry(
      id: jsonSerialization['id'] as String,
      level: _i2.EnergyLevel.fromJson((jsonSerialization['level'] as String)),
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      hourOfDay: jsonSerialization['hourOfDay'] as int,
    );
  }

  /// Unique identifier
  String id;

  /// The energy level logged
  _i2.EnergyLevel level;

  /// When this energy level was recorded
  DateTime timestamp;

  /// Hour of day (0-23) for pattern analysis
  int hourOfDay;

  /// Returns a shallow copy of this [EnergyEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EnergyEntry copyWith({
    String? id,
    _i2.EnergyLevel? level,
    DateTime? timestamp,
    int? hourOfDay,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnergyEntry',
      'id': id,
      'level': level.toJson(),
      'timestamp': timestamp.toJson(),
      'hourOfDay': hourOfDay,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EnergyEntryImpl extends EnergyEntry {
  _EnergyEntryImpl({
    required String id,
    required _i2.EnergyLevel level,
    required DateTime timestamp,
    required int hourOfDay,
  }) : super._(
         id: id,
         level: level,
         timestamp: timestamp,
         hourOfDay: hourOfDay,
       );

  /// Returns a shallow copy of this [EnergyEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EnergyEntry copyWith({
    String? id,
    _i2.EnergyLevel? level,
    DateTime? timestamp,
    int? hourOfDay,
  }) {
    return EnergyEntry(
      id: id ?? this.id,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      hourOfDay: hourOfDay ?? this.hourOfDay,
    );
  }
}
