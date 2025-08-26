import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/models/weather_data.dart';

// Current weather provider with caching
final currentWeatherProvider = FutureProvider<WeatherData>((ref) async {
  return await WeatherService.getCurrentWeather();
});

// Weather forecast provider
final weatherForecastProvider = FutureProvider.family<List<WeatherData>, int>((ref, days) async {
  return await WeatherService.getForecast(days: days);
});

// Weather message provider based on current conditions
final weatherMessageProvider = Provider<String>((ref) {
  final weatherAsync = ref.watch(currentWeatherProvider);
  
  return weatherAsync.when(
    data: (weather) => WeatherService.getWeatherMessage(weather.condition),
    loading: () => 'Loading weather data...',
    error: (_, __) => 'Your garden is looking great! 🌱',
  );
});

// Garden care recommendation based on weather
final gardenCareRecommendationProvider = Provider<String>((ref) {
  final weatherAsync = ref.watch(currentWeatherProvider);
  
  return weatherAsync.when(
    data: (weather) => _getGardenRecommendation(weather),
    loading: () => 'Checking weather for garden tips...',
    error: (_, __) => 'Perfect day for plant care! 🌿',
  );
});

String _getGardenRecommendation(WeatherData weather) {
  final temp = weather.temperature;
  final condition = weather.condition;
  final humidity = weather.humidity;
  
  if (condition == WeatherCondition.rainy) {
    return 'Great day to skip watering - let nature do the work! 🌧️';
  }
  
  if (condition == WeatherCondition.sunny && temp > 25) {
    return 'Hot and sunny! Water early morning or evening. ☀️';
  }
  
  if (condition == WeatherCondition.cloudy && humidity > 70) {
    return 'Perfect gentle conditions for fertilizing! ☁️';
  }
  
  if (temp < 10) {
    return 'Cool weather - perfect for indoor plant care! 🏠';
  }
  
  if (condition == WeatherCondition.windy) {
    return 'Windy day - secure tall plants and check stakes! 💨';
  }
  
  return 'Beautiful weather for spending time with your plants! 🌱';
}
