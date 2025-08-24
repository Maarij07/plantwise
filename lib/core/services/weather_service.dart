import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _apiKey = 'your_api_key_here'; // Replace with actual API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _londonCityId = '2643743'; // London, UK city ID
  
  // Fallback weather data for when API is not available
  static const WeatherData _fallbackWeather = WeatherData(
    temperature: 18.5,
    condition: WeatherCondition.partlyCloudy,
    humidity: 65,
    windSpeed: 12.4,
    description: 'Partly cloudy with gentle breeze',
    cityName: 'London',
    country: 'UK',
  );

  static Future<WeatherData> getCurrentWeather() async {
    try {
      // For demo purposes, we'll cycle through different weather conditions
      // In production, uncomment the API call below
      
      // For London, show current cloudy weather conditions
      // Since it's cloudy in London, we'll prioritize cloudy weather
      final currentTime = DateTime.now();
      final currentHour = currentTime.hour;
      final currentMinute = currentTime.minute;
      
      // Mock weather data for demo - prioritizing cloudy London weather
      final mockWeathers = [
        // Cloudy conditions (more frequent for London)
        const WeatherData(
          temperature: 15.2,
          condition: WeatherCondition.cloudy,
          humidity: 78,
          windSpeed: 12.1,
          description: 'Overcast skies with grey cloud cover',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 17.8,
          condition: WeatherCondition.cloudy,
          humidity: 74,
          windSpeed: 9.5,
          description: 'Dense clouds blocking most sunlight',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 13.9,
          condition: WeatherCondition.cloudy,
          humidity: 82,
          windSpeed: 14.3,
          description: 'Heavy cloud cover with cool temperatures',
          cityName: 'London',
          country: 'UK',
        ),
        // Partly cloudy (transitional weather)
        const WeatherData(
          temperature: 18.5,
          condition: WeatherCondition.partlyCloudy,
          humidity: 65,
          windSpeed: 11.2,
          description: 'Cloudy with brief sunny spells',
          cityName: 'London',
          country: 'UK',
        ),
        // Occasional other conditions
        const WeatherData(
          temperature: 16.3,
          condition: WeatherCondition.rainy,
          humidity: 85,
          windSpeed: 15.7,
          description: 'Light drizzle with cloudy skies',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 12.1,
          condition: WeatherCondition.foggy,
          humidity: 94,
          windSpeed: 4.8,
          description: 'Misty conditions with reduced visibility',
          cityName: 'London',
          country: 'UK',
        ),
      ];
      
      // Weighted selection favoring cloudy weather (typical for London)
      // 60% chance cloudy, 20% partly cloudy, 20% other conditions
      int weatherIndex;
      final random = (currentHour * 60 + currentMinute) % 100;
      
      if (random < 60) {
        // 60% cloudy weather
        weatherIndex = random % 3; // First 3 items are cloudy
      } else if (random < 80) {
        // 20% partly cloudy
        weatherIndex = 3; // Partly cloudy item
      } else {
        // 20% other conditions
        weatherIndex = 4 + (random % 2); // Rainy or foggy
      }
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('🌧️ London Weather: ${mockWeathers[weatherIndex].condition.displayName} - ${mockWeathers[weatherIndex].temperatureString}');
      
      return mockWeathers[weatherIndex];
      
      /* 
      // Uncomment this for actual API integration:
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?id=$_londonCityId&appid=$_apiKey&units=metric'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('Weather API Error: ${response.statusCode}');
        return _fallbackWeather;
      }
      */
      
    } catch (e) {
      print('Weather Service Error: $e');
      return _fallbackWeather;
    }
  }

  static Future<List<WeatherData>> getForecast({int days = 5}) async {
    try {
      // Mock forecast data for demo
      final baseMockWeathers = [
        const WeatherData(
          temperature: 20.1,
          condition: WeatherCondition.sunny,
          humidity: 52,
          windSpeed: 7.8,
          description: 'Clear sunny skies',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 17.5,
          condition: WeatherCondition.partlyCloudy,
          humidity: 68,
          windSpeed: 12.3,
          description: 'Mix of sun and clouds',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 15.2,
          condition: WeatherCondition.rainy,
          humidity: 82,
          windSpeed: 16.7,
          description: 'Scattered showers',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 18.8,
          condition: WeatherCondition.cloudy,
          humidity: 75,
          windSpeed: 10.2,
          description: 'Mostly cloudy',
          cityName: 'London',
          country: 'UK',
        ),
        const WeatherData(
          temperature: 23.4,
          condition: WeatherCondition.sunny,
          humidity: 41,
          windSpeed: 6.9,
          description: 'Bright and sunny',
          cityName: 'London',
          country: 'UK',
        ),
      ];
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 750));
      
      return baseMockWeathers.take(days).toList();
      
      /* 
      // Uncomment this for actual API integration:
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?id=$_londonCityId&appid=$_apiKey&units=metric&cnt=${days * 8}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList.map((item) => WeatherData.fromJson({
          'main': item['main'],
          'weather': item['weather'],
          'wind': item['wind'],
          'name': 'London',
          'sys': {'country': 'UK'},
        })).take(days).toList();
      } else {
        return List.filled(days, _fallbackWeather);
      }
      */
      
    } catch (e) {
      print('Weather Forecast Error: $e');
      return List.filled(days, _fallbackWeather);
    }
  }
  
  static String getWeatherMessage(WeatherCondition condition) {
    const messages = {
      WeatherCondition.sunny: [
        'Perfect sunshine for your garden! ☀️',
        'Your plants are loving this sunshine! 🌞',
        'Great day for outdoor gardening! ☀️',
        'Bright and beautiful garden weather! 🌻',
      ],
      WeatherCondition.partlyCloudy: [
        'Your garden is thriving! 🌱',
        'Perfect mix of sun and clouds! ⛅',
        'Ideal growing conditions today! 🌿',
        'Your plants are happy and healthy! 🪴',
      ],
      WeatherCondition.cloudy: [
        'Gentle light for sensitive plants! ☁️',
        'Your garden stays cool and comfortable! 🌿',
        'Perfect for shade-loving plants! 🍃',
        'Cloudy days are great for growth! ☁️',
      ],
      WeatherCondition.rainy: [
        'Natural watering for your garden! 🌧️',
        'Your plants are getting refreshed! 💧',
        'Rain brings life to your garden! 🌱',
        'Perfect day to stay cozy indoors! ☔',
      ],
      WeatherCondition.thunderstorm: [
        'Dramatic weather energizes nature! ⛈️',
        'Thunder brings nutrients to soil! ⚡',
        'Powerful rains nourish the earth! 🌩️',
        'Nature\'s spectacular light show! ⛈️',
      ],
      WeatherCondition.snowy: [
        'Winter wonder protects your garden! ❄️',
        'Snow blanket keeps roots warm! ⛄',
        'Magical winter garden scene! ❄️',
        'Perfect time for indoor plants! 🏠',
      ],
      WeatherCondition.foggy: [
        'Mysterious morning in the garden! 🌫️',
        'Gentle mist nurtures your plants! 💨',
        'Mystical garden atmosphere today! 🌫️',
        'Soft conditions for delicate growth! 🌿',
      ],
      WeatherCondition.windy: [
        'Fresh breeze energizes your garden! 💨',
        'Wind helps pollination naturally! 🍃',
        'Your plants dance in the breeze! 🌾',
        'Breezy day brings fresh air! 💨',
      ],
    };
    
    final messageList = messages[condition] ?? messages[WeatherCondition.partlyCloudy]!;
    final randomIndex = DateTime.now().millisecond % messageList.length;
    return messageList[randomIndex];
  }
}
