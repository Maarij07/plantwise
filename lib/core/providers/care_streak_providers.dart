import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/care_streak_service.dart';
import '../../features/plants/domain/models/plant.dart';
import '../../features/plants/presentation/providers/plants_provider.dart';

/// Provider for care streak service instance
final careStreakServiceProvider = Provider<CareStreakService>((ref) {
  return CareStreakService.instance;
});

/// Provider for current care streak count
final careStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.read(careStreakServiceProvider);
  return service.getCareStreak();
});

/// Provider for overall care statistics
final careStatisticsProvider = FutureProvider<CareStatistics>((ref) async {
  final service = ref.read(careStreakServiceProvider);
  return service.getCareStatistics();
});

/// Provider for weekly goal progress
final weeklyGoalProgressProvider = FutureProvider<WeeklyGoalProgress>((ref) async {
  final service = ref.read(careStreakServiceProvider);
  return service.getWeeklyGoalProgress();
});

/// Provider for recent care actions
final recentCareActionsProvider = FutureProvider<List<CareAction>>((ref) async {
  final service = ref.read(careStreakServiceProvider);
  return service.getRecentCareActions();
});

/// Provider for overall health score based on all plants
final overallHealthScoreProvider = Provider<AsyncValue<double>>((ref) {
  final plantsAsync = ref.watch(plantsProvider);
  final service = ref.read(careStreakServiceProvider);
  
  return plantsAsync.when(
    data: (plants) => AsyncValue.data(service.calculateHealthScore(plants)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for dashboard stats combining all metrics
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final plantsAsync = ref.watch(plantsProvider);
  final plantsNeedingWaterAsync = ref.watch(plantsNeedingWaterProvider);
  final careStatsAsync = ref.watch(careStatisticsProvider);
  final healthScoreAsync = ref.watch(overallHealthScoreProvider);
  
  // Wait for all async values to be available
  final plants = await plantsAsync.when(
    data: (data) async => data,
    loading: () async => <Plant>[],
    error: (error, stack) async => <Plant>[],
  );
  
  final plantsNeedingWater = await plantsNeedingWaterAsync.when(
    data: (data) async => data,
    loading: () async => <Plant>[],
    error: (error, stack) async => <Plant>[],
  );
  
  final careStats = await careStatsAsync.when(
    data: (data) async => data,
    loading: () async => CareStatistics(
      totalPlantsWatered: 0,
      totalPlantsFertilized: 0,
      currentStreak: 0,
      weeklyProgress: WeeklyGoalProgress(
        completedTasks: 0,
        targetTasks: 7,
        progress: 0.0,
      ),
    ),
    error: (error, stack) async => CareStatistics(
      totalPlantsWatered: 0,
      totalPlantsFertilized: 0,
      currentStreak: 0,
      weeklyProgress: WeeklyGoalProgress(
        completedTasks: 0,
        targetTasks: 7,
        progress: 0.0,
      ),
    ),
  );
  
  final healthScore = await healthScoreAsync.when(
    data: (data) async => data,
    loading: () async => 75.0,
    error: (error, stack) async => 75.0,
  );
  
  return DashboardStats(
    totalPlants: plants.length,
    plantsNeedingWater: plantsNeedingWater.length,
    overallHealthScore: healthScore,
    careStreak: careStats.currentStreak,
    weeklyGoalProgress: careStats.weeklyProgress,
  );
});

/// Dashboard statistics model
class DashboardStats {
  final int totalPlants;
  final int plantsNeedingWater;
  final double overallHealthScore;
  final int careStreak;
  final WeeklyGoalProgress weeklyGoalProgress;
  
  const DashboardStats({
    required this.totalPlants,
    required this.plantsNeedingWater,
    required this.overallHealthScore,
    required this.careStreak,
    required this.weeklyGoalProgress,
  });
  
  /// Get health score as percentage string
  String get healthScorePercentage => '${overallHealthScore.round()}%';
  
  /// Get health status description
  String get healthStatusDescription {
    if (overallHealthScore >= 90) return 'Excellent';
    if (overallHealthScore >= 75) return 'Good';
    if (overallHealthScore >= 60) return 'Fair';
    if (overallHealthScore >= 40) return 'Poor';
    return 'Needs Attention';
  }
  
  /// Get streak description
  String get streakDescription {
    if (careStreak == 0) return 'Start your streak!';
    if (careStreak == 1) return '1 day';
    return '$careStreak days';
  }
  
  /// Get weekly progress description  
  String get weeklyProgressDescription {
    final completed = weeklyGoalProgress.completedTasks;
    final target = weeklyGoalProgress.targetTasks;
    return '$completed/$target tasks';
  }
}
