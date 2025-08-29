import 'package:shared_preferences/shared_preferences.dart';
import '../../features/plants/domain/models/plant.dart';

/// Service for tracking care streaks and achievements
class CareStreakService {
  static CareStreakService? _instance;
  static CareStreakService get instance => _instance ??= CareStreakService._();
  
  CareStreakService._();

  static const String _streakCountKey = 'care_streak_count';
  static const String _lastCareDate = 'last_care_date';
  static const String _totalPlantsWatered = 'total_plants_watered';
  static const String _totalPlantsFertilized = 'total_plants_fertilized';
  static const String _weeklyGoalKey = 'weekly_goal_progress';
  static const String _weekStartKey = 'week_start_date';

  /// Get current care streak (consecutive days of plant care)
  Future<int> getCareStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streakCount = prefs.getInt(_streakCountKey) ?? 0;
    final lastCareDateString = prefs.getString(_lastCareDate);
    
    if (lastCareDateString == null) return 0;
    
    final lastCareDate = DateTime.parse(lastCareDateString);
    final now = DateTime.now();
    final daysSinceLastCare = now.difference(lastCareDate).inDays;
    
    // If more than 1 day has passed, reset streak
    if (daysSinceLastCare > 1) {
      await _resetStreak();
      return 0;
    }
    
    return streakCount;
  }

  /// Update care streak when user performs plant care action
  Future<void> updateCareStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCareDateString = prefs.getString(_lastCareDate);
    
    if (lastCareDateString == null) {
      // First time caring for plants
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_lastCareDate, today.toIso8601String());
      return;
    }
    
    final lastCareDate = DateTime.parse(lastCareDateString);
    final lastCareDay = DateTime(lastCareDate.year, lastCareDate.month, lastCareDate.day);
    final daysDifference = today.difference(lastCareDay).inDays;
    
    if (daysDifference == 0) {
      // Already cared for plants today, no change needed
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increase streak
      final currentStreak = prefs.getInt(_streakCountKey) ?? 0;
      await prefs.setInt(_streakCountKey, currentStreak + 1);
      await prefs.setString(_lastCareDate, today.toIso8601String());
    } else {
      // Gap in care, reset streak
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_lastCareDate, today.toIso8601String());
    }
  }

  /// Reset care streak
  Future<void> _resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakCountKey, 0);
    await prefs.remove(_lastCareDate);
  }

  /// Track watering action
  Future<void> trackWateringAction() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_totalPlantsWatered) ?? 0;
    await prefs.setInt(_totalPlantsWatered, currentCount + 1);
    await updateCareStreak();
    await _updateWeeklyProgress();
  }

  /// Track fertilizing action
  Future<void> trackFertilizingAction() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_totalPlantsFertilized) ?? 0;
    await prefs.setInt(_totalPlantsFertilized, currentCount + 1);
    await updateCareStreak();
    await _updateWeeklyProgress();
  }

  /// Get weekly goal progress (tasks completed this week)
  Future<WeeklyGoalProgress> getWeeklyGoalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetWeekIfNeeded();
    
    final completedTasks = prefs.getInt(_weeklyGoalKey) ?? 0;
    const targetTasks = 7; // Goal: at least 1 care action per day
    
    return WeeklyGoalProgress(
      completedTasks: completedTasks,
      targetTasks: targetTasks,
      progress: (completedTasks / targetTasks).clamp(0.0, 1.0),
    );
  }

  /// Update weekly progress
  Future<void> _updateWeeklyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetWeekIfNeeded();
    
    final currentProgress = prefs.getInt(_weeklyGoalKey) ?? 0;
    await prefs.setInt(_weeklyGoalKey, currentProgress + 1);
  }

  /// Check if we need to reset weekly progress (new week started)
  Future<void> _checkAndResetWeekIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);
    final savedWeekStartString = prefs.getString(_weekStartKey);
    
    if (savedWeekStartString == null) {
      // First time, set current week
      await prefs.setString(_weekStartKey, startOfWeek.toIso8601String());
      await prefs.setInt(_weeklyGoalKey, 0);
      return;
    }
    
    final savedWeekStart = DateTime.parse(savedWeekStartString);
    if (startOfWeek.isAfter(savedWeekStart)) {
      // New week started, reset progress
      await prefs.setString(_weekStartKey, startOfWeek.toIso8601String());
      await prefs.setInt(_weeklyGoalKey, 0);
    }
  }

  /// Get start of week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  /// Get total care statistics
  Future<CareStatistics> getCareStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final totalWatered = prefs.getInt(_totalPlantsWatered) ?? 0;
    final totalFertilized = prefs.getInt(_totalPlantsFertilized) ?? 0;
    final currentStreak = await getCareStreak();
    final weeklyProgress = await getWeeklyGoalProgress();
    
    return CareStatistics(
      totalPlantsWatered: totalWatered,
      totalPlantsFertilized: totalFertilized,
      currentStreak: currentStreak,
      weeklyProgress: weeklyProgress,
    );
  }

  /// Calculate overall health score based on plant statuses
  double calculateHealthScore(List<Plant> plants) {
    if (plants.isEmpty) return 0.0;
    
    double totalScore = 0;
    int plantsWithStatus = 0;
    
    for (final plant in plants) {
      if (plant.healthStatus != null) {
        plantsWithStatus++;
        switch (plant.healthStatus!) {
          case HealthStatus.excellent:
            totalScore += 100;
            break;
          case HealthStatus.good:
            totalScore += 80;
            break;
          case HealthStatus.fair:
            totalScore += 60;
            break;
          case HealthStatus.poor:
            totalScore += 40;
            break;
          case HealthStatus.critical:
            totalScore += 20;
            break;
        }
      }
    }
    
    if (plantsWithStatus == 0) return 75.0; // Default score if no health status set
    
    return totalScore / plantsWithStatus;
  }

  /// Get plants that need water based on care schedule
  List<Plant> getPlantsNeedingWater(List<Plant> plants) {
    final now = DateTime.now();
    return plants.where((plant) {
      if (plant.lastWatered == null) return true;
      final daysSinceWatered = now.difference(plant.lastWatered!).inDays;
      return daysSinceWatered >= plant.careSchedule.wateringIntervalDays;
    }).toList();
  }

  /// Get recent care actions for activity feed
  Future<List<CareAction>> getRecentCareActions() async {
    // In a real implementation, this would be stored in Firebase
    // For now, return mock data based on streak
    final streak = await getCareStreak();
    if (streak == 0) return [];
    
    final now = DateTime.now();
    final actions = <CareAction>[];
    
    // Add recent actions based on streak
    for (int i = 0; i < streak && i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      actions.add(CareAction(
        type: i.isEven ? CareActionType.watered : CareActionType.fertilized,
        plantName: _getRandomPlantName(),
        timestamp: date,
      ));
    }
    
    return actions;
  }

  String _getRandomPlantName() {
    final names = ['Monstera Deliciosa', 'Snake Plant', 'Fiddle Leaf Fig', 'Peace Lily', 'Rubber Plant'];
    return names[DateTime.now().millisecond % names.length];
  }
}

/// Weekly goal progress data
class WeeklyGoalProgress {
  final int completedTasks;
  final int targetTasks;
  final double progress;
  
  const WeeklyGoalProgress({
    required this.completedTasks,
    required this.targetTasks,
    required this.progress,
  });
}

/// Overall care statistics
class CareStatistics {
  final int totalPlantsWatered;
  final int totalPlantsFertilized;
  final int currentStreak;
  final WeeklyGoalProgress weeklyProgress;
  
  const CareStatistics({
    required this.totalPlantsWatered,
    required this.totalPlantsFertilized,
    required this.currentStreak,
    required this.weeklyProgress,
  });
}

/// Care action types
enum CareActionType {
  watered,
  fertilized,
  healthCheck,
  repotted,
}

/// Individual care action
class CareAction {
  final CareActionType type;
  final String plantName;
  final DateTime timestamp;
  
  const CareAction({
    required this.type,
    required this.plantName,
    required this.timestamp,
  });
  
  String get displayName {
    switch (type) {
      case CareActionType.watered:
        return 'Watered';
      case CareActionType.fertilized:
        return 'Fertilized';
      case CareActionType.healthCheck:
        return 'Health Check';
      case CareActionType.repotted:
        return 'Repotted';
    }
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
