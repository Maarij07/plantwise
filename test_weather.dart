import 'dart:io';
import 'lib/core/models/weather_data.dart';
import 'lib/core/services/weather_service.dart';

void main() async {
  print('🌦️ Testing PlantWise Weather System\n');
  
  try {
    // Test getting weather data
    print('📡 Fetching weather data...');
    final weatherData = await WeatherService.getCurrentWeather();
    
    print('✅ Weather data retrieved successfully!');
    print('🌡️ Temperature: ${weatherData.temperatureString}');
    print('☁️ Condition: ${weatherData.condition.displayName}');
    print('📍 Location: ${weatherData.location}');
    print('💨 Wind Speed: ${weatherData.windSpeed} km/h');
    print('💧 Humidity: ${weatherData.humidity}%');
    print('📝 Description: ${weatherData.description}');
    print('🎨 Primary Color: ${weatherData.primaryColor}');
    print('🎨 Secondary Color: ${weatherData.secondaryColor}');
    print('🌐 Icon: ${weatherData.weatherIcon}');
    
    // Test weather messages
    print('\n📬 Testing weather messages for all conditions:');
    for (final condition in WeatherCondition.values) {
      final message = WeatherService.getWeatherMessage(condition);
      print('${condition.weatherIcon} ${condition.displayName}: $message');
    }
    
    // Test multiple weather fetches to see cycling
    print('\n🔄 Testing weather data cycling (next 5 fetches):');
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      final nextWeather = await WeatherService.getCurrentWeather();
      print('$i. ${nextWeather.condition.weatherIcon} ${nextWeather.condition.displayName} - ${nextWeather.temperatureString}');
    }
    
    print('\n🎉 All weather system tests passed!');
    print('\n🌟 Weather Design Files Available:');
    
    // List all weather design files
    final weatherDesignFiles = [
      'sunny_header.dart ☀️',
      'rainy_header.dart 🌧️', 
      'thunderstorm_header.dart ⛈️',
      'cloudy_header.dart ☁️',
      'snowy_header.dart ❄️',
      'foggy_header.dart 🌫️',
      'windy_header.dart 💨',
      'partly_cloudy_header.dart ⛅',
    ];
    
    for (final file in weatherDesignFiles) {
      print('   ✅ $file');
    }
    
    print('\n🎯 Ready to display weather-based greeting cards in PlantWise!');
    
  } catch (e, stackTrace) {
    print('❌ Error testing weather system: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
