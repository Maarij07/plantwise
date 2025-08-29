import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/disease_detection.dart';
import '../../data/services/disease_detection_service.dart';
import 'add_plant_screen.dart';

class CameraPlantScreen extends ConsumerStatefulWidget {
  const CameraPlantScreen({super.key});

  @override
  ConsumerState<CameraPlantScreen> createState() => _CameraPlantScreenState();
}

class _CameraPlantScreenState extends ConsumerState<CameraPlantScreen> {
  File? _capturedImage;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  DiseaseDetectionResult? _detectionResult;
  
  final ImagePicker _imagePicker = ImagePicker();
  final DiseaseDetectionService _diseaseService = DiseaseDetectionService.instance;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    _initializeMLService();
  }

  Future<void> _checkCameraPermission() async {
    final permission = await Permission.camera.status;
    if (permission.isDenied) {
      await Permission.camera.request();
    }
  }

  Future<void> _initializeMLService() async {
    final success = await _diseaseService.initialize();
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize disease detection. Some features may not work.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identify Plant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            if (_capturedImage == null) ...[
              // Camera Instructions
              _buildCameraInstructions(),
              const SizedBox(height: 32),
              
              // Camera Action Buttons
              _buildCameraActions(),
            ] else ...[
              // Captured Image
              _buildCapturedImage(),
              const SizedBox(height: 24),
              
              // Analysis Section
              if (_isAnalyzing) 
                _buildAnalyzingWidget()
              else if (_detectionResult != null)
                _buildDetectionResults()
              else
                _buildAnalysisActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraInstructions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Plant Identification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Take a clear photo of your plant to identify it and get care recommendations.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Tips for better identification:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('📸', 'Capture the entire plant if possible'),
                  _buildTip('💡', 'Use good lighting'),
                  _buildTip('🍃', 'Include leaves, flowers, or distinguishing features'),
                  _buildTip('📐', 'Keep the plant centered and in focus'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedImage() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _capturedImage!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnalyzingWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing plant...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we identify your plant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _analyzeImage,
            icon: const Icon(Icons.search),
            label: const Text('Identify Plant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retakePhoto,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addManually,
                icon: const Icon(Icons.edit),
                label: const Text('Add Manually'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildResultItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _capturedImage = File(pickedFile.path);
          _detectionResult = null; // Reset previous results
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Run disease detection using our ML service
      final result = await _diseaseService.detectDiseases(_capturedImage!);
      
      setState(() {
        _detectionResult = result;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Widget _buildDetectionResults() {
    final result = _detectionResult!;
    final hasDetections = result.detections.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  hasDetections ? Icons.warning : Icons.check_circle,
                  color: hasDetections ? AppColors.warning : AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasDetections ? 'Disease Detection Results' : 'Plant Looks Healthy!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasDetections ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Processing time: ${result.processingTimeMs.toStringAsFixed(0)}ms',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (hasDetections) ...[
              ...result.detections.asMap().entries.map((entry) {
                final index = entry.key;
                final detection = entry.value;
                return _buildDetectionItem(detection, index);
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.eco,
                      color: AppColors.success,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Great news! No diseases detected in your plant.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakePhoto,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addManually,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Plant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionItem(DetectedDisease detection, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: detection.severityLevel.level >= 3 
            ? AppColors.error.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: detection.severityLevel.level >= 3 
              ? AppColors.error.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease name and confidence
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: detection.severityLevel.level >= 3 
                      ? AppColors.error
                      : AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.diseaseName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      detection.plantType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: detection.severityLevel.level >= 3 
                      ? AppColors.error
                      : AppColors.warning,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  detection.confidencePercentage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Severity and description
          if (detection.description != null && detection.description!.isNotEmpty) ...[
            Text(
              detection.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
          
          // Severity indicator
          Row(
            children: [
              Text(
                'Severity: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: detection.severityLevel.level >= 3 
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detection.severityLevel.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: detection.severityLevel.level >= 3 
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          
          // Treatment suggestions
          if (detection.treatmentSuggestions != null && detection.treatmentSuggestions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
              title: Text(
                'Treatment Suggestions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              children: detection.treatmentSuggestions!.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }


  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _detectionResult = null;
    });
  }

  void _addManually() {
    // Navigate to manual add with the captured image
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AddPlantScreen(preSelectedImage: _capturedImage),
      ),
    );
  }


  int _getDefaultWateringInterval(PlantType type) {
    switch (type) {
      case PlantType.succulent:
        return 14;
      case PlantType.flowering:
        return 5;
      case PlantType.herb:
        return 3;
      case PlantType.vegetable:
        return 2;
      case PlantType.fruit:
        return 4;
      default:
        return 7;
    }
  }

  int _getDefaultFertilizingInterval(PlantType type) {
    switch (type) {
      case PlantType.succulent:
        return 60;
      case PlantType.flowering:
        return 14;
      case PlantType.herb:
        return 21;
      case PlantType.vegetable:
        return 14;
      case PlantType.fruit:
        return 21;
      default:
        return 30;
    }
  }
}

// Model for plant identification result
class PlantIdentificationResult {
  final String name;
  final String scientificName;
  final PlantType type;
  final double confidence;
  final List<String> careNotes;

  PlantIdentificationResult({
    required this.name,
    required this.scientificName,
    required this.type,
    required this.confidence,
    required this.careNotes,
  });
}

// Extension for the add plant screen with pre-filled image
class AddPlantScreenWithImage extends StatelessWidget {
  final File? image;

  const AddPlantScreenWithImage({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    // This would be a modified version of AddPlantScreen with pre-filled image
    // For now, just navigate to the regular AddPlantScreen
    return const AddPlantScreen();
  }
}

