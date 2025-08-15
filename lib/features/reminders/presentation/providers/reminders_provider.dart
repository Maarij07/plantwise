import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/reminder.dart';
import '../../../plants/domain/models/plant.dart';
import '../../../plants/presentation/providers/plants_provider.dart';

final remindersProvider = StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier(ref);
});

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  final Ref _ref;
  
  RemindersNotifier(this._ref) : super([]) {
    _loadReminders();
    _generateAutomaticReminders();
  }

  static const String _remindersKey = 'reminders';

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey);
    
    if (remindersJson != null) {
      state = remindersJson
          .map((json) => Reminder.fromJson(jsonDecode(json)))
          .toList();
    }
    
    // Clean up old completed reminders (older than 30 days)
    _cleanupOldReminders();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = state
        .map((reminder) => jsonEncode(reminder.toJson()))
        .toList();
    await prefs.setStringList(_remindersKey, remindersJson);
  }

  Future<void> _cleanupOldReminders() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final filteredReminders = state.where((reminder) {
      if (reminder.isCompleted == true && reminder.completedAt != null) {
        return reminder.completedAt!.isAfter(thirtyDaysAgo);
      }
      return true;
    }).toList();
    
    if (filteredReminders.length != state.length) {
      state = filteredReminders;
      await _saveReminders();
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    state = [...state, reminder];
    await _saveReminders();
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    state = state.map((reminder) {
      if (reminder.id == updatedReminder.id) {
        return updatedReminder;
      }
      return reminder;
    }).toList();
    await _saveReminders();
  }

  Future<void> deleteReminder(String reminderId) async {
    state = state.where((reminder) => reminder.id != reminderId).toList();
    await _saveReminders();
  }

  Future<void> completeReminder(String reminderId) async {
    final now = DateTime.now();
    state = state.map((reminder) {
      if (reminder.id == reminderId) {
        var updatedReminder = reminder.copyWith(
          isCompleted: true,
          completedAt: now,
        );
        
        // If it's a recurring reminder, create the next one
        if (reminder.frequency != null && reminder.frequency != ReminderFrequency.custom) {
          _createNextRecurringReminder(reminder);
        }
        
        return updatedReminder;
      }
      return reminder;
    }).toList();
    await _saveReminders();
  }

  Future<void> _createNextRecurringReminder(Reminder completedReminder) async {
    if (completedReminder.frequency == null) return;
    
    final nextDate = DateTime.now().add(Duration(days: completedReminder.frequency!.days));
    final nextReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantId: completedReminder.plantId,
      plantName: completedReminder.plantName,
      type: completedReminder.type,
      scheduledDate: nextDate,
      createdAt: DateTime.now(),
      frequency: completedReminder.frequency,
      notes: completedReminder.notes,
    );
    
    await addReminder(nextReminder);
  }

  Future<void> snoozeReminder(String reminderId, Duration snoozeDuration) async {
    state = state.map((reminder) {
      if (reminder.id == reminderId) {
        return reminder.copyWith(
          scheduledDate: DateTime.now().add(snoozeDuration),
        );
      }
      return reminder;
    }).toList();
    await _saveReminders();
  }

  // Generate automatic reminders based on plant care schedules
  Future<void> _generateAutomaticReminders() async {
    final plants = _ref.read(plantsProvider);
    final now = DateTime.now();
    
    for (final plant in plants) {
      await _generateWateringReminders(plant, now);
      await _generateFertilizingReminders(plant, now);
    }
  }

  Future<void> _generateWateringReminders(Plant plant, DateTime baseDate) async {
    // Check if there's already an active watering reminder for this plant
    final existingWateringReminder = state.where((reminder) =>
        reminder.plantId == plant.id &&
        reminder.type == ReminderType.watering &&
        reminder.isCompleted != true).isNotEmpty;

    if (existingWateringReminder) return;

    DateTime nextWateringDate;
    if (plant.lastWatered != null) {
      nextWateringDate = plant.lastWatered!.add(
        Duration(days: plant.careSchedule.wateringIntervalDays),
      );
    } else {
      // If never watered, schedule for tomorrow
      nextWateringDate = baseDate.add(const Duration(days: 1));
    }

    // Only create reminder if it's in the future or due today
    if (nextWateringDate.isAfter(baseDate.subtract(const Duration(hours: 12)))) {
      final reminder = Reminder(
        id: '${plant.id}_watering_${nextWateringDate.millisecondsSinceEpoch}',
        plantId: plant.id,
        plantName: plant.name,
        type: ReminderType.watering,
        scheduledDate: nextWateringDate,
        createdAt: baseDate,
        frequency: _getFrequencyFromDays(plant.careSchedule.wateringIntervalDays),
        notes: 'Water every ${plant.careSchedule.wateringIntervalDays} days',
      );

      await addReminder(reminder);
    }
  }

  Future<void> _generateFertilizingReminders(Plant plant, DateTime baseDate) async {
    // Check if there's already an active fertilizing reminder for this plant
    final existingFertilizingReminder = state.where((reminder) =>
        reminder.plantId == plant.id &&
        reminder.type == ReminderType.fertilizing &&
        reminder.isCompleted != true).isNotEmpty;

    if (existingFertilizingReminder) return;

    DateTime nextFertilizingDate;
    if (plant.lastFertilized != null) {
      nextFertilizingDate = plant.lastFertilized!.add(
        Duration(days: plant.careSchedule.fertilizingIntervalDays),
      );
    } else {
      // If never fertilized, schedule for next week
      nextFertilizingDate = baseDate.add(const Duration(days: 7));
    }

    // Only create reminder if it's in the future or due today
    if (nextFertilizingDate.isAfter(baseDate.subtract(const Duration(hours: 12)))) {
      final reminder = Reminder(
        id: '${plant.id}_fertilizing_${nextFertilizingDate.millisecondsSinceEpoch}',
        plantId: plant.id,
        plantName: plant.name,
        type: ReminderType.fertilizing,
        scheduledDate: nextFertilizingDate,
        createdAt: baseDate,
        frequency: _getFrequencyFromDays(plant.careSchedule.fertilizingIntervalDays),
        notes: 'Fertilize every ${plant.careSchedule.fertilizingIntervalDays} days',
      );

      await addReminder(reminder);
    }
  }

  ReminderFrequency _getFrequencyFromDays(int days) {
    if (days == 1) return ReminderFrequency.daily;
    if (days == 7) return ReminderFrequency.weekly;
    if (days == 14) return ReminderFrequency.biweekly;
    if (days == 30) return ReminderFrequency.monthly;
    if (days == 90) return ReminderFrequency.quarterly;
    if (days == 365) return ReminderFrequency.yearly;
    return ReminderFrequency.custom;
  }

  // When plants are updated, refresh automatic reminders
  Future<void> refreshAutomaticReminders() async {
    await _generateAutomaticReminders();
  }

  // Get reminders filtered by various criteria
  List<Reminder> getOverdueReminders() {
    return state.where((reminder) => reminder.isOverdue).toList();
  }

  List<Reminder> getTodayReminders() {
    final today = DateTime.now();
    return state.where((reminder) {
      if (reminder.isCompleted == true) return false;
      return reminder.scheduledDate.day == today.day &&
             reminder.scheduledDate.month == today.month &&
             reminder.scheduledDate.year == today.year;
    }).toList();
  }

  List<Reminder> getUpcomingReminders() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return state.where((reminder) {
      if (reminder.isCompleted == true) return false;
      return reminder.scheduledDate.isAfter(now) &&
             reminder.scheduledDate.isBefore(nextWeek);
    }).toList();
  }

  List<Reminder> getRemindersByPlant(String plantId) {
    return state.where((reminder) => reminder.plantId == plantId).toList();
  }

  List<Reminder> getRemindersByType(ReminderType type) {
    return state.where((reminder) => reminder.type == type).toList();
  }

  int getActiveRemindersCount() {
    return state.where((reminder) => reminder.isCompleted != true).length;
  }

  int getOverdueRemindersCount() {
    return getOverdueReminders().length;
  }

  int getTodayRemindersCount() {
    return getTodayReminders().length;
  }
}

// Computed providers
final overdueRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersNotifier = ref.watch(remindersProvider.notifier);
  ref.watch(remindersProvider); // Watch for changes
  return remindersNotifier.getOverdueReminders();
});

final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersNotifier = ref.watch(remindersProvider.notifier);
  ref.watch(remindersProvider); // Watch for changes
  return remindersNotifier.getTodayReminders();
});

final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersNotifier = ref.watch(remindersProvider.notifier);
  ref.watch(remindersProvider); // Watch for changes
  return remindersNotifier.getUpcomingReminders();
});

final reminderStatsProvider = Provider<Map<String, int>>((ref) {
  final remindersNotifier = ref.watch(remindersProvider.notifier);
  ref.watch(remindersProvider); // Watch for changes
  
  return {
    'active': remindersNotifier.getActiveRemindersCount(),
    'overdue': remindersNotifier.getOverdueRemindersCount(),
    'today': remindersNotifier.getTodayRemindersCount(),
    'upcoming': remindersNotifier.getUpcomingReminders().length,
  };
});
