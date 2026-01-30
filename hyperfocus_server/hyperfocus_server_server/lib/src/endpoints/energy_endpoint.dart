import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:uuid/uuid.dart';

/// In-memory storage for energy entries (mini version without DB)
final _energyEntries = <String, EnergyEntry>{};
final _uuid = Uuid();

/// Endpoint for managing energy logging and patterns
class EnergyEndpoint extends Endpoint {
  /// Log a new energy level entry
  Future<EnergyEntry> logEnergy(Session session, EnergyLevel level) async {
    final now = DateTime.now();
    final entry = EnergyEntry(
      id: _uuid.v4(),
      level: level,
      timestamp: now,
      hourOfDay: now.hour,
    );
    _energyEntries[entry.id] = entry;
    return entry;
  }

  /// Get energy entries for today
  Future<List<EnergyEntry>> getToday(Session session) async {
    final todayStart = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final entries = _energyEntries.values
        .where((e) => e.timestamp.isAfter(todayStart))
        .toList();
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  /// Get energy patterns by hour (average over past week)
  Future<Map<int, EnergyLevel>> getHourlyPatterns(Session session) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final entries = _energyEntries.values
        .where((e) => e.timestamp.isAfter(weekAgo))
        .toList();

    // Group by hour and calculate most common energy level
    final hourlyData = <int, List<EnergyLevel>>{};
    for (final entry in entries) {
      hourlyData.putIfAbsent(entry.hourOfDay, () => []);
      hourlyData[entry.hourOfDay]!.add(entry.level);
    }

    // Return most frequent level per hour
    final patterns = <int, EnergyLevel>{};
    for (final hour in hourlyData.keys) {
      final levels = hourlyData[hour]!;
      final counts = <EnergyLevel, int>{};
      for (final level in levels) {
        counts[level] = (counts[level] ?? 0) + 1;
      }
      patterns[hour] = counts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
    return patterns;
  }

  /// Get current energy level (most recent entry)
  Future<EnergyEntry?> getCurrent(Session session) async {
    if (_energyEntries.isEmpty) return null;

    final entries = _energyEntries.values.toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.first;
  }
}
