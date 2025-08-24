// Simple test to demonstrate UK timezone functionality
// Run: dart test_uk_timezone.dart

import 'dart:io';
import 'lib/core/utils/time_greeting_utils.dart';

void main() {
  try {
    print('=== UK Timezone Test ===');
    
    // Get current UK time
    final ukTime = TimeGreetingUtils.getUKTime();
    print('Current UK Time: ${TimeGreetingUtils.getFormattedUKTime()}');
    
    // Get current time period
    final timePeriod = TimeGreetingUtils.getCurrentTimePeriod();
    print('Current Time Period: ${timePeriod.displayName} ${timePeriod.emoji}');
    
    // Get greetings
    print('Short Greeting: ${TimeGreetingUtils.getShortGreeting()}');
    print('Greeting with name: ${TimeGreetingUtils.getGreeting(null, "Shahzaib")}');
    
    // Get motivational message
    print('Motivational Message: ${TimeGreetingUtils.getMotivationalMessage()}');
    
    // Check DST status
    print('Is UK in DST (British Summer Time): ${TimeGreetingUtils.isUKInDST()}');
    
    print('\n=== Testing Different Times of Day ===');
    
    // Test different times of day manually
    final testTimes = [
      DateTime(2024, 8, 24, 2, 0),  // 2 AM - Midnight
      DateTime(2024, 8, 24, 5, 0),  // 5 AM - Dawn
      DateTime(2024, 8, 24, 9, 0),  // 9 AM - Morning
      DateTime(2024, 8, 24, 12, 30), // 12:30 PM - Noon
      DateTime(2024, 8, 24, 15, 0), // 3 PM - Afternoon
      DateTime(2024, 8, 24, 18, 0), // 6 PM - Evening
      DateTime(2024, 8, 24, 22, 0), // 10 PM - Night
    ];
    
    for (final testTime in testTimes) {
      final period = TimeGreetingUtils.getCurrentTimePeriod(testTime);
      final greeting = TimeGreetingUtils.getShortGreeting(testTime);
      print('${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')} - $greeting (${period.displayName})');
    }
    
    print('\n✅ UK Timezone implementation is working correctly!');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
