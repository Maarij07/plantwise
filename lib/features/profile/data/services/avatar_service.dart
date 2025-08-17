import 'dart:math';
import 'package:http/http.dart' as http;

class AvatarService {
  static const String _baseUrl = 'https://api.dicebear.com/7.x';
  
  // Available avatar styles - professional and modern looking
  static const Map<String, String> _avatarStyles = {
    'adventurer': 'adventurer', // Illustrated people
    'adventurer-neutral': 'adventurer-neutral', // Gender neutral
    'avataaars': 'avataaars', // Bitmoji-style
    'avataaars-neutral': 'avataaars-neutral', // Gender neutral avataaars
    'big-smile': 'big-smile', // Happy faces
    'fun-emoji': 'fun-emoji', // Emoji style
    'lorelei': 'lorelei', // Feminine style
    'lorelei-neutral': 'lorelei-neutral', // Neutral feminine
    'micah': 'micah', // Masculine style
    'miniavs': 'miniavs', // Minimal avatars
    'notionists': 'notionists', // Notion-style
    'open-peeps': 'open-peeps', // Diverse illustrations
    'personas': 'personas', // Professional portraits
  };

  // Generate avatar URL with customization
  static String generateAvatarUrl({
    String? seed,
    String? gender,
    String? style,
    int size = 200,
    Map<String, dynamic>? customOptions,
  }) {
    // Choose style based on gender preference
    String selectedStyle = _getStyleForGender(gender, style);
    
    // Use user identifier as seed for consistency
    String avatarSeed = seed ?? _generateRandomSeed();
    
    // Build query parameters
    Map<String, String> params = {
      'seed': avatarSeed,
      'size': size.toString(),
      'format': 'svg',
      ...?_getGenderSpecificOptions(gender),
      ...?_convertCustomOptions(customOptions),
    };

    // Build URL
    String queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_baseUrl/$selectedStyle/svg?$queryString';
  }

  // Get style based on gender preference
  static String _getStyleForGender(String? gender, String? preferredStyle) {
    if (preferredStyle != null && _avatarStyles.containsKey(preferredStyle)) {
      return _avatarStyles[preferredStyle]!;
    }

    switch (gender?.toLowerCase()) {
      case 'male':
        return _avatarStyles['micah']!; // Masculine style
      case 'female':
        return _avatarStyles['lorelei']!; // Feminine style
      case 'non-binary':
      case 'other':
        return _avatarStyles['adventurer-neutral']!; // Gender neutral
      default:
        return _avatarStyles['avataaars']!; // Default Bitmoji-style
    }
  }

  // Generate random seed for new users
  static String _generateRandomSeed() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Get gender-specific styling options
  static Map<String, String>? _getGenderSpecificOptions(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return {
          'hairProbability': '80',
          'facialHairProbability': '30',
        };
      case 'female':
        return {
          'hairProbability': '90',
          'accessoriesProbability': '40',
        };
      default:
        return {
          'hairProbability': '75',
        };
    }
  }

  // Convert custom options to URL parameters
  static Map<String, String>? _convertCustomOptions(Map<String, dynamic>? options) {
    if (options == null) return null;
    
    return options.map((key, value) => MapEntry(key, value.toString()));
  }

  // Pre-defined avatar configurations for common use cases
  static Map<String, dynamic> getPresetConfig(String preset) {
    switch (preset) {
      case 'professional':
        return {
          'style': 'personas',
          'backgroundColor': ['f1f4f8', 'ffffff', 'e2e8f0'].join(','),
          'accessories': ['glasses'],
          'accessoriesProbability': '20',
        };
      case 'friendly':
        return {
          'style': 'big-smile',
          'backgroundColor': ['fef3c7', 'fde68a', 'fed7aa'].join(','),
          'mood': ['happy', 'blissful'].join(','),
        };
      case 'minimal':
        return {
          'style': 'miniavs',
          'backgroundColor': ['f8fafc', 'f1f5f9', 'e2e8f0'].join(','),
        };
      case 'garden-theme':
        return {
          'style': 'adventurer',
          'backgroundColor': ['dcfce7', 'd1fae5', 'bbf7d0'].join(','),
          'hairColor': ['2d5016', '365314', '4d7c0f'].join(','),
        };
      default:
        return {};
    }
  }

  // Fetch avatar as SVG string (for caching or manipulation)
  static Future<String?> fetchAvatarSvg(String avatarUrl) async {
    try {
      final response = await http.get(Uri.parse(avatarUrl));
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Error fetching avatar: $e');
      return null;
    }
  }

  // Generate multiple avatar options for user to choose from
  static List<String> generateAvatarOptions({
    String? gender,
    String? baseSeed,
    int count = 6,
  }) {
    List<String> avatars = [];
    String seed = baseSeed ?? _generateRandomSeed();
    
    // Generate variations using different styles and slight seed modifications
    List<String> styles = gender?.toLowerCase() == 'male' 
        ? ['micah', 'avataaars', 'adventurer']
        : gender?.toLowerCase() == 'female'
        ? ['lorelei', 'avataaars', 'adventurer']
        : ['adventurer-neutral', 'avataaars-neutral', 'personas'];

    for (int i = 0; i < count; i++) {
      String modifiedSeed = '${seed}_$i';
      String style = styles[i % styles.length];
      
      avatars.add(generateAvatarUrl(
        seed: modifiedSeed,
        gender: gender,
        style: style,
        size: 200,
      ));
    }

    return avatars;
  }
}
