import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../profile/domain/models/land_size.dart';

final landSizeProvider = StateNotifierProvider<LandSizeNotifier, LandSize?>((ref) {
  return LandSizeNotifier(ref);
});

class LandSizeNotifier extends StateNotifier<LandSize?> {
  final Ref _ref;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  LandSizeNotifier(this._ref) 
    : _firestore = FirebaseFirestore.instance,
      _auth = FirebaseAuth.instance,
      super(null) {
    _loadLandSize();
  }

  static const String _landSizeKey = 'land_size';
  static const String _landUnitKey = 'land_unit';

  Future<void> _loadLandSize() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Try to load from Firestore first
        final doc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final landSizeData = data['landSize'] as Map<String, dynamic>?;
          
          if (landSizeData != null) {
            final landSize = LandSize.fromJson(landSizeData);
            state = landSize;
            
            // Also cache locally for offline access
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble(_landSizeKey, landSize.value);
            await prefs.setString(_landUnitKey, landSize.unit);
            return;
          }
        }
      }
      
      // Fallback to local storage if Firestore fails or user is not authenticated
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getDouble(_landSizeKey);
      final unit = prefs.getString(_landUnitKey);
      
      if (value != null && unit != null) {
        state = LandSize(value: value, unit: unit);
      }
    } catch (e) {
      print('Error loading land size: $e');
      
      // Fallback to local storage on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        final value = prefs.getDouble(_landSizeKey);
        final unit = prefs.getString(_landUnitKey);
        
        if (value != null && unit != null) {
          state = LandSize(value: value, unit: unit);
        }
      } catch (localError) {
        print('Error loading from local storage: $localError');
      }
    }
  }

  Future<void> setLandSize(double value, LandUnit unit) async {
    final landSize = LandSize(value: value, unit: unit.symbol);
    
    try {
      // Update state immediately for better UX
      state = landSize;
      
      // Save to local storage first (for offline access)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_landSizeKey, value);
      await prefs.setString(_landUnitKey, unit.symbol);
      
      // Save to Firestore if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'landSize': landSize.toJson(),
          'landSizeUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('Land size saved to Firestore successfully');
      } else {
        print('User not authenticated, land size saved locally only');
      }
    } catch (e) {
      print('Error saving land size: $e');
      
      // Try to save locally if Firestore fails
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_landSizeKey, value);
        await prefs.setString(_landUnitKey, unit.symbol);
        print('Land size saved locally as fallback');
      } catch (localError) {
        print('Failed to save land size locally: $localError');
        // Revert state if both saves fail
        await _loadLandSize();
        throw Exception('Failed to save land size: $e');
      }
    }
  }

  Future<void> clearLandSize() async {
    try {
      // Clear state immediately
      state = null;
      
      // Clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_landSizeKey);
      await prefs.remove(_landUnitKey);
      
      // Clear from Firestore if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'landSize': FieldValue.delete(),
          'landSizeUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error clearing land size: $e');
      throw Exception('Failed to clear land size: $e');
    }
  }

  // Reload land size from Firestore (useful after user authentication changes)
  Future<void> reload() async {
    await _loadLandSize();
  }

  bool get isLandSizeSet => state != null;
}
