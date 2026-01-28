import '../models/energy_level.dart';

class EnergyTracker {
  static const String storageKey = 'energy_entries';

  /// Records user's current energy level
  static Future<EnergyEntry> recordEnergyLevel(int level, String? note) async {
    assert(level >= 1 && level <= 100);
    
    final entry = EnergyEntry(
      level: level,
      intensity: EnergyEntry.getLevelFromInt(level),
      note: note,
    );

    // In production, this would save to persistent storage
    return entry;
  }

  /// Analyzes energy patterns to identify peak productivity hours
  static Future<Map<int, double>> analyzeEnergyPattern(
    List<EnergyEntry> entries,
  ) async {
    if (entries.isEmpty) {
      return {};
    }

    final byHour = <int, List<int>>{};

    for (var entry in entries) {
      final hour = entry.timestamp.hour;
      byHour.putIfAbsent(hour, () => []);
      byHour[hour]!.add(entry.level);
    }

    final averageByHour = <int, double>{};
    byHour.forEach((hour, levels) {
      averageByHour[hour] =
          levels.fold(0, (sum, level) => sum + level) / levels.length;
    });

    return averageByHour;
  }

  /// Gets energy recommendation based on current level
  static String getEnergyRecommendation(EnergyIntensity intensity) {
    switch (intensity) {
      case EnergyIntensity.veryLow:
        return 'Your energy is very low. Consider taking a break, meditating, or doing light scatterfocus tasks.';
      case EnergyIntensity.low:
        return 'Your energy is low. This is a good time for creative scatterfocus work or self-care.';
      case EnergyIntensity.moderate:
        return 'Your energy is moderate. You can handle balanced work - mix hyperfocus and scatterfocus tasks.';
      case EnergyIntensity.high:
        return 'Your energy is high! Great time for important hyperfocus tasks.';
      case EnergyIntensity.veryHigh:
        return 'Your energy is at peak! Perfect for intense, challenging hyperfocus work.';
    }
  }

  /// Predicts energy level based on time of day and historical data
  static Future<int> predictEnergyLevel(
    List<DailyEnergyPattern> history,
    int hour,
  ) async {
    if (history.isEmpty) return 50;

    double totalEnergy = 0;
    int count = 0;

    for (var dayPattern in history) {
      final hourEntries = dayPattern.getEntriesByHour(hour);
      for (var entry in hourEntries) {
        totalEnergy += entry.level;
        count++;
      }
    }

    if (count == 0) return 50;
    return (totalEnergy / count).toInt();
  }
}
