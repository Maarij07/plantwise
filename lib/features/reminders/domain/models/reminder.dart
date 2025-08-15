import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String plantId,
    required String plantName,
    required ReminderType type,
    required DateTime scheduledDate,
    required DateTime createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    String? notes,
    ReminderFrequency? frequency,
    DateTime? nextScheduledDate,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
}

enum ReminderType {
  watering('Watering', Icons.water_drop, Color(0xFF2196F3)),
  fertilizing('Fertilizing', Icons.grass, Color(0xFF4CAF50)),
  repotting('Repotting', Icons.local_florist, Color(0xFFFF9800)),
  pruning('Pruning', Icons.cut, Color(0xFF9C27B0)),
  inspection('Health Check', Icons.visibility, Color(0xFF607D8B)),
  custom('Custom', Icons.notifications, Color(0xFF795548));

  const ReminderType(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}

enum ReminderFrequency {
  daily('Daily', 1),
  weekly('Weekly', 7),
  biweekly('Bi-weekly', 14),
  monthly('Monthly', 30),
  quarterly('Quarterly', 90),
  yearly('Yearly', 365),
  custom('Custom', 0);

  const ReminderFrequency(this.displayName, this.days);

  final String displayName;
  final int days;
}

// Extension to add computed properties
extension ReminderExtension on Reminder {
  bool get isDue {
    if (isCompleted == true) return false;
    return DateTime.now().isAfter(scheduledDate);
  }
  
  bool get isOverdue {
    if (isCompleted == true) return false;
    final now = DateTime.now();
    return now.isAfter(scheduledDate.add(const Duration(hours: 12)));
  }
  
  Duration get timeUntilDue {
    return scheduledDate.difference(DateTime.now());
  }
  
  String get timeUntilDueText {
    final duration = timeUntilDue;
    if (duration.isNegative) {
      final overdueDuration = duration.abs();
      if (overdueDuration.inDays > 0) {
        return '${overdueDuration.inDays} day${overdueDuration.inDays > 1 ? 's' : ''} overdue';
      } else if (overdueDuration.inHours > 0) {
        return '${overdueDuration.inHours} hour${overdueDuration.inHours > 1 ? 's' : ''} overdue';
      } else {
        return 'Just overdue';
      }
    } else {
      if (duration.inDays > 0) {
        return 'In ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
      } else if (duration.inHours > 0) {
        return 'In ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
      } else {
        return 'Due soon';
      }
    }
  }
  
  ReminderUrgency get urgency {
    if (isCompleted == true) return ReminderUrgency.completed;
    
    final now = DateTime.now();
    final hoursUntilDue = scheduledDate.difference(now).inHours;
    
    if (hoursUntilDue < 0) return ReminderUrgency.overdue;
    if (hoursUntilDue <= 2) return ReminderUrgency.urgent;
    if (hoursUntilDue <= 24) return ReminderUrgency.today;
    if (hoursUntilDue <= 72) return ReminderUrgency.soon;
    
    return ReminderUrgency.upcoming;
  }
}

enum ReminderUrgency {
  overdue('Overdue', Color(0xFFD32F2F)),
  urgent('Urgent', Color(0xFFFF5722)),
  today('Today', Color(0xFFFF9800)),
  soon('Soon', Color(0xFFFFC107)),
  upcoming('Upcoming', Color(0xFF4CAF50)),
  completed('Completed', Color(0xFF9E9E9E));

  const ReminderUrgency(this.displayName, this.color);

  final String displayName;
  final Color color;
}
