import '../utils/datetime_utils.dart';

enum EnergyIntensity { veryLow, low, moderate, high, veryHigh }

class EnergyEntry {
  final String id;
  final EnergyIntensity intensity;
  final int level; // 1-100 scale
  final DateTime timestamp;
  final String? note;

  EnergyEntry({
    String? id,
    required this.intensity,
    required this.level,
    DateTime? timestamp,
    this.note,
  })  : id = id ?? DateTimeUtils.generateId(),
        timestamp = timestamp ?? DateTime.now() {
    assert(level >= 1 && level <= 100, 'Energy level must be between 1 and 100');
  }

  static EnergyIntensity getLevelFromInt(int level) {
    if (level <= 20) return EnergyIntensity.veryLow;
    if (level <= 40) return EnergyIntensity.low;
    if (level <= 60) return EnergyIntensity.moderate;
    if (level <= 80) return EnergyIntensity.high;
    return EnergyIntensity.veryHigh;
  }

  EnergyEntry copyWith({
    String? id,
    EnergyIntensity? intensity,
    int? level,
    DateTime? timestamp,
    String? note,
  }) {
    return EnergyEntry(
      id: id ?? this.id,
      intensity: intensity ?? this.intensity,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'EnergyEntry(id: $id, intensity: $intensity, level: $level, timestamp: $timestamp)';
  }
}

class DailyEnergyPattern {
  final DateTime date;
  final List<EnergyEntry> entries;

  DailyEnergyPattern({
    required this.date,
    required this.entries,
  });

  double getAverageEnergy() {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.level) / entries.length;
  }

  int getHourWithHighestEnergy() {
    if (entries.isEmpty) return 0;
    EnergyEntry highest = entries[0];
    for (var entry in entries) {
      if (entry.level > highest.level) {
        highest = entry;
      }
    }
    return highest.timestamp.hour;
  }

  List<EnergyEntry> getEntriesByHour(int hour) {
    return entries.where((e) => e.timestamp.hour == hour).toList();
  }
}
