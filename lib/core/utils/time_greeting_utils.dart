import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Time period enumeration
enum TimePeriod {
  midnight(0, 4, 'Midnight', '🌙', Colors.indigo),
  dawn(4, 6, 'Dawn', '🌅', Colors.orange),
  morning(6, 12, 'Morning', '🌞', Colors.amber),
  noon(12, 13, 'Noon', '☀️', Colors.yellow),
  afternoon(13, 17, 'Afternoon', '🌤️', Colors.blue),
  evening(17, 20, 'Evening', '🌆', Colors.deepOrange),
  night(20, 24, 'Night', '🌃', Colors.purple);

  const TimePeriod(this.startHour, this.endHour, this.displayName, this.emoji, this.color);

  final int startHour;
  final int endHour;
  final String displayName;
  final String emoji;
  final Color color;
}

/// Utility class for time-based greetings and periods
class TimeGreetingUtils {
  /// Map of time periods for quick lookup
  static const List<TimePeriod> _timePeriods = TimePeriod.values;
  
  /// Get current time in UK timezone
  static DateTime getUKTime() {
    final utcTime = DateTime.now().toUtc();
    // UK timezone offset changes between GMT (0) and BST (+1) based on DST
    // Using a more accurate approach with timezone-aware calculation
    return _convertToUKTime(utcTime);
  }
  
  /// Convert UTC time to UK timezone with DST handling
  static DateTime _convertToUKTime(DateTime utcTime) {
    // Basic DST calculation for Europe/London (UK)
    // DST starts last Sunday in March, ends last Sunday in October
    final year = utcTime.year;
    
    // Find last Sunday in March (DST start)
    final marchLastSunday = _getLastSundayOfMonth(year, 3);
    
    // Find last Sunday in October (DST end) 
    final octoberLastSunday = _getLastSundayOfMonth(year, 10);
    
    // Check if current date is within DST period
    final isDST = utcTime.isAfter(marchLastSunday) && utcTime.isBefore(octoberLastSunday);
    
    // Apply appropriate offset: GMT (0) or BST (+1)
    final offset = isDST ? 1 : 0;
    return utcTime.add(Duration(hours: offset));
  }
  
  /// Get the last Sunday of a given month and year
  static DateTime _getLastSundayOfMonth(int year, int month) {
    // Get last day of month
    final lastDay = DateTime(year, month + 1, 0);
    
    // Find last Sunday (weekday 7 = Sunday)
    final daysToSubtract = lastDay.weekday % 7;
    return DateTime(year, month, lastDay.day - daysToSubtract, 2, 0); // 2 AM for DST transition
  }

  /// Get current time period based on hour (uses UK timezone by default)
  static TimePeriod getCurrentTimePeriod([DateTime? dateTime]) {
    final now = dateTime ?? getUKTime();
    final hour = now.hour;

    for (final period in _timePeriods) {
      if (period == TimePeriod.midnight) {
        // Special case for midnight (0-4 hours)
        if (hour >= period.startHour && hour < period.endHour) {
          return period;
        }
      } else if (period == TimePeriod.night) {
        // Special case for night (20-24 hours)
        if (hour >= period.startHour || hour == 0) {
          return period;
        }
      } else {
        // Regular time periods
        if (hour >= period.startHour && hour < period.endHour) {
          return period;
        }
      }
    }
    
    return TimePeriod.morning; // Default fallback
  }

  /// Get greeting message based on current time
  static String getGreeting([DateTime? dateTime, String? userName]) {
    final period = getCurrentTimePeriod(dateTime);
    final name = userName ?? '';
    
    switch (period) {
      case TimePeriod.midnight:
        return name.isEmpty ? 'Good Midnight' : 'Good Midnight, $name';
      case TimePeriod.dawn:
        return name.isEmpty ? 'Good Dawn' : 'Good Dawn, $name';
      case TimePeriod.morning:
        return name.isEmpty ? 'Good Morning' : 'Good Morning, $name';
      case TimePeriod.noon:
        return name.isEmpty ? 'Good Noon' : 'Good Noon, $name';
      case TimePeriod.afternoon:
        return name.isEmpty ? 'Good Afternoon' : 'Good Afternoon, $name';
      case TimePeriod.evening:
        return name.isEmpty ? 'Good Evening' : 'Good Evening, $name';
      case TimePeriod.night:
        return name.isEmpty ? 'Good Night' : 'Good Night, $name';
    }
  }

  /// Get short greeting without name
  static String getShortGreeting([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    return 'Good ${period.displayName}';
  }

  /// Get greeting with emoji
  static String getGreetingWithEmoji([DateTime? dateTime, String? userName]) {
    final period = getCurrentTimePeriod(dateTime);
    final greeting = getGreeting(dateTime, userName);
    return '$greeting ${period.emoji}';
  }

  /// Get period-specific motivational message
  static String getMotivationalMessage([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    
    switch (period) {
      case TimePeriod.midnight:
        return 'Rest well, your plants are sleeping too! 🌙';
      case TimePeriod.dawn:
        return 'Early bird gets the best garden time! 🌅';
      case TimePeriod.morning:
        return 'Perfect time for plant care! 🌱';
      case TimePeriod.noon:
        return 'Peak sunlight - check your plants! ☀️';
      case TimePeriod.afternoon:
        return 'Great time for garden planning! 🌿';
      case TimePeriod.evening:
        return 'Your garden is thriving! 🌆';
      case TimePeriod.night:
        return 'Sweet dreams, garden lover! 🌃';
    }
  }

  /// Get period-specific gardening tip
  static String getGardeningTip([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    
    switch (period) {
      case TimePeriod.midnight:
        return 'Plants love quiet nights for growth';
      case TimePeriod.dawn:
        return 'Dawn dew provides natural hydration';
      case TimePeriod.morning:
        return 'Morning is ideal for watering plants';
      case TimePeriod.noon:
        return 'Check for plants needing shade';
      case TimePeriod.afternoon:
        return 'Great time for pruning and maintenance';
      case TimePeriod.evening:
        return 'Evening watering helps roots absorb';
      case TimePeriod.night:
        return 'Plants repair and grow during night';
    }
  }

  /// Get period color for theming
  static Color getPeriodColor([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    return period.color;
  }

  /// Get period emoji
  static String getPeriodEmoji([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    return period.emoji;
  }

  /// Check if it's a good time for specific garden activities
  static Map<String, bool> getActivityRecommendations([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    
    switch (period) {
      case TimePeriod.midnight:
        return {
          'watering': false,
          'pruning': false,
          'planting': false,
          'fertilizing': false,
          'harvesting': false,
        };
      case TimePeriod.dawn:
        return {
          'watering': true,
          'pruning': false,
          'planting': false,
          'fertilizing': false,
          'harvesting': true,
        };
      case TimePeriod.morning:
        return {
          'watering': true,
          'pruning': true,
          'planting': true,
          'fertilizing': true,
          'harvesting': true,
        };
      case TimePeriod.noon:
        return {
          'watering': false, // Too hot
          'pruning': false,
          'planting': false,
          'fertilizing': false,
          'harvesting': false,
        };
      case TimePeriod.afternoon:
        return {
          'watering': false,
          'pruning': true,
          'planting': false,
          'fertilizing': false,
          'harvesting': true,
        };
      case TimePeriod.evening:
        return {
          'watering': true,
          'pruning': false,
          'planting': false,
          'fertilizing': false,
          'harvesting': true,
        };
      case TimePeriod.night:
        return {
          'watering': false,
          'pruning': false,
          'planting': false,
          'fertilizing': false,
          'harvesting': false,
        };
    }
  }

  /// Get formatted time period display
  static String getFormattedTimePeriod([DateTime? dateTime]) {
    final period = getCurrentTimePeriod(dateTime);
    return '${period.emoji} ${period.displayName}';
  }
  
  // --- UK-specific convenience methods ---
  
  /// Get greeting message based on UK time
  static String getUKGreeting([String? userName]) {
    return getGreeting(getUKTime(), userName);
  }
  
  /// Get short greeting based on UK time
  static String getUKShortGreeting() {
    return getShortGreeting(getUKTime());
  }
  
  /// Get motivational message based on UK time
  static String getUKMotivationalMessage() {
    return getMotivationalMessage(getUKTime());
  }
  
  /// Get gardening tip based on UK time
  static String getUKGardeningTip() {
    return getGardeningTip(getUKTime());
  }
  
  /// Get current UK time period
  static TimePeriod getUKTimePeriod() {
    return getCurrentTimePeriod(getUKTime());
  }
  
  /// Get formatted UK time display (for debugging)
  static String getFormattedUKTime() {
    final ukTime = getUKTime();
    return DateFormat('yyyy-MM-dd HH:mm:ss (Europe/London)').format(ukTime);
  }
  
  /// Check if UK is currently in DST (British Summer Time)
  static bool isUKInDST() {
    final utcTime = DateTime.now().toUtc();
    final year = utcTime.year;
    
    final marchLastSunday = _getLastSundayOfMonth(year, 3);
    final octoberLastSunday = _getLastSundayOfMonth(year, 10);
    
    return utcTime.isAfter(marchLastSunday) && utcTime.isBefore(octoberLastSunday);
  }
}
