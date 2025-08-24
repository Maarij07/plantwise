import 'package:flutter/material.dart';

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  thunderstorm,
  snowy,
  foggy,
  windy,
}

extension WeatherConditionExtension on WeatherCondition {
  String get displayName {
    switch (this) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.foggy:
        return 'Foggy';
      case WeatherCondition.windy:
        return 'Windy';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.grain;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.foggy:
        return Icons.foggy;
      case WeatherCondition.windy:
        return Icons.air;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case WeatherCondition.sunny:
        return [
          const Color(0xFFFFB74D), // Orange 300
          const Color(0xFFF57C00), // Orange 700
        ];
      case WeatherCondition.partlyCloudy:
        return [
          const Color(0xFF81C784), // Green 300
          const Color(0xFF2E7D32), // Green 700
        ];
      case WeatherCondition.cloudy:
        return [
          const Color(0xFF90A4AE), // Blue Grey 300
          const Color(0xFF455A64), // Blue Grey 700
        ];
      case WeatherCondition.rainy:
        return [
          const Color(0xFF64B5F6), // Blue 300
          const Color(0xFF1565C0), // Blue 800
        ];
      case WeatherCondition.thunderstorm:
        return [
          const Color(0xFF5C6BC0), // Indigo 400
          const Color(0xFF283593), // Indigo 700
        ];
      case WeatherCondition.snowy:
        return [
          const Color(0xFFE1F5FE), // Light Blue 50
          const Color(0xFF81D4FA), // Light Blue 200
        ];
      case WeatherCondition.foggy:
        return [
          const Color(0xFFCFD8DC), // Blue Grey 100
          const Color(0xFF78909C), // Blue Grey 400
        ];
      case WeatherCondition.windy:
        return [
          const Color(0xFFA5D6A7), // Green 200
          const Color(0xFF43A047), // Green 600
        ];
    }
  }

  Color get primaryColor {
    return gradientColors.first;
  }

  Color get secondaryColor {
    return gradientColors.last;
  }

  String get weatherIcon {
    switch (this) {
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.partlyCloudy:
        return '⛅';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.thunderstorm:
        return '⛈️';
      case WeatherCondition.snowy:
        return '❄️';
      case WeatherCondition.foggy:
        return '🌫️';
      case WeatherCondition.windy:
        return '💨';
    }
  }
}

class WeatherData {
  final double temperature;
  final WeatherCondition condition;
  final int humidity;
  final double windSpeed;
  final String description;
  final String cityName;
  final String country;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.cityName,
    required this.country,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final wind = json['wind'];

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      condition: _mapWeatherCondition(weather['main'] as String),
      humidity: main['humidity'] as int,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] as String,
      cityName: json['name'] as String,
      country: json['sys']?['country'] as String? ?? '',
    );
  }

  static WeatherCondition _mapWeatherCondition(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return WeatherCondition.sunny;
      case 'clouds':
        return WeatherCondition.cloudy;
      case 'rain':
      case 'drizzle':
        return WeatherCondition.rainy;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snowy;
      case 'mist':
      case 'fog':
      case 'haze':
        return WeatherCondition.foggy;
      case 'dust':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return WeatherCondition.windy;
      default:
        return WeatherCondition.partlyCloudy;
    }
  }

  String get temperatureString => '${temperature.round()}°C';
  
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} m/s';
  
  String get humidityString => '$humidity%';

  String get location => '$cityName, $country';
  
  String get weatherIcon => condition.weatherIcon;
  
  Color get primaryColor => condition.primaryColor;
  
  Color get secondaryColor => condition.secondaryColor;

  @override
  String toString() {
    return 'WeatherData{temperature: $temperature, condition: $condition, humidity: $humidity, windSpeed: $windSpeed, description: $description, cityName: $cityName, country: $country}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherData &&
        other.temperature == temperature &&
        other.condition == condition &&
        other.humidity == humidity &&
        other.windSpeed == windSpeed &&
        other.description == description &&
        other.cityName == cityName &&
        other.country == country;
  }

  @override
  int get hashCode {
    return temperature.hashCode ^
        condition.hashCode ^
        humidity.hashCode ^
        windSpeed.hashCode ^
        description.hashCode ^
        cityName.hashCode ^
        country.hashCode;
  }
}
