import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profile/domain/models/land_size.dart';

final landSizeProvider = StateNotifierProvider<LandSizeNotifier, LandSize?>((ref) {
  return LandSizeNotifier();
});

class LandSizeNotifier extends StateNotifier<LandSize?> {
  LandSizeNotifier() : super(null) {
    _loadLandSize();
  }

  static const String _landSizeKey = 'land_size';
  static const String _landUnitKey = 'land_unit';

  Future<void> _loadLandSize() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_landSizeKey);
    final unit = prefs.getString(_landUnitKey);
    
    if (value != null && unit != null) {
      state = LandSize(value: value, unit: unit);
    }
  }

  Future<void> setLandSize(double value, LandUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_landSizeKey, value);
    await prefs.setString(_landUnitKey, unit.symbol);
    
    state = LandSize(value: value, unit: unit.symbol);
  }

  Future<void> clearLandSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_landSizeKey);
    await prefs.remove(_landUnitKey);
    
    state = null;
  }

  bool get isLandSizeSet => state != null;
}
