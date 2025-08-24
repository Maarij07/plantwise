import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request notification permission with custom dialog
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    // Check if permission is already granted
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    // Show custom permission dialog
    final shouldRequest = await _showPermissionDialog(
      context,
      title: 'Stay Updated! 🔔',
      subtitle: 'Never miss plant care reminders',
      description: 'PlantWise needs notification permissions to send you:\n\n'
          '🌱 Watering reminders\n'
          '🌿 Fertilizing schedules\n'
          '📊 Plant health updates\n'
          '💬 Community activity',
      icon: Icons.notifications_outlined,
      primaryColor: Theme.of(context).colorScheme.primary,
    );

    if (!shouldRequest) return false;

    // Request the actual permission
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// Request camera and media permissions with custom dialog
  static Future<bool> requestMediaPermissions(BuildContext context) async {
    // Check current status
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;
    final storageStatus = await Permission.storage.status;

    if (cameraStatus.isGranted && 
        (photosStatus.isGranted || storageStatus.isGranted)) {
      return true;
    }

    // Show custom permission dialog
    final shouldRequest = await _showPermissionDialog(
      context,
      title: 'Capture & Identify! 📸',
      subtitle: 'Discover plants through your camera',
      description: 'PlantWise needs camera and media permissions to:\n\n'
          '📷 Take photos of plants\n'
          '🔍 Identify plants automatically\n'
          '🖼️ Save plant photos to gallery\n'
          '📱 Access your plant photo library',
      icon: Icons.camera_alt_outlined,
      primaryColor: Theme.of(context).colorScheme.secondary,
    );

    if (!shouldRequest) return false;

    // Request the actual permissions
    final results = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    return results[Permission.camera]!.isGranted && 
           (results[Permission.photos]!.isGranted || 
            results[Permission.storage]!.isGranted);
  }

  /// Show a custom permission request dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color primaryColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 24,
              vertical: isTablet ? 60 : 40,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background
                  Container(
                    width: isTablet ? 80 : 64,
                    height: isTablet ? 80 : 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 40 : 32),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: isTablet ? 40 : 32,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 24 : 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: isTablet ? 12 : 8),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: isTablet ? 16 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: isTablet ? 24 : 20),
                  
                  // Description
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: isTablet ? 14 : 13,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Buttons
                  Column(
                    children: [
                      // Allow button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Allow',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 16 : 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 16 : 12),
                      
                      // Not now button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Not Now',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              fontSize: isTablet ? 16 : 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isTablet ? 16 : 12),
                  
                  // Fine print
                  Text(
                    'You can change these permissions later in Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: isTablet ? 12 : 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }

  /// Open app settings for manual permission changes
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
