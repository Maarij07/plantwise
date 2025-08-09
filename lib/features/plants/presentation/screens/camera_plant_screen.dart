import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/plant.dart';
import '../providers/plants_provider.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart'; // For PlantType color extension

class CameraPlantScreen extends ConsumerStatefulWidget {
  const CameraPlantScreen({super.key});

  @override
  ConsumerState<CameraPlantScreen> createState() => _CameraPlantScreenState();
}

class _CameraPlantScreenState extends ConsumerState<CameraPlantScreen> {
  File? _capturedImage;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  PlantIdentificationResult? _identificationResult;
  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final permission = await Permission.camera.status;
    if (permission.isDenied) {
      await Permission.camera.request();
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
              else if (_identificationResult != null)
                _buildIdentificationResult()
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

  Widget _buildIdentificationResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Plant Identified!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildResultItem(
              'Name',
              _identificationResult!.name,
              Icons.eco,
            ),
            _buildResultItem(
              'Scientific Name',
              _identificationResult!.scientificName,
              Icons.science,
            ),
            _buildResultItem(
              'Type',
              _identificationResult!.type.displayName,
              _identificationResult!.type.icon,
            ),
            _buildResultItem(
              'Confidence',
              '${(_identificationResult!.confidence * 100).toInt()}%',
              Icons.trending_up,
            ),
            
            if (_identificationResult!.careNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Care Tips:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._identificationResult!.careNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $note',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addIdentifiedPlant,
                icon: const Icon(Icons.add),
                label: const Text('Add to My Plants'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
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
          _identificationResult = null; // Reset previous results
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
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock plant identification result
      // In a real app, you would call a plant identification API here
      setState(() {
        _identificationResult = _getMockIdentificationResult();
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

  PlantIdentificationResult _getMockIdentificationResult() {
    // Mock result - in a real app, this would come from an API
    final random = DateTime.now().millisecond % 3;
    switch (random) {
      case 0:
        return PlantIdentificationResult(
          name: 'Monstera Deliciosa',
          scientificName: 'Monstera deliciosa',
          type: PlantType.foliage,
          confidence: 0.92,
          careNotes: [
            'Prefers bright, indirect light',
            'Water when top inch of soil is dry',
            'Loves humidity - mist regularly',
            'Can grow up to 10 feet indoors',
          ],
        );
      case 1:
        return PlantIdentificationResult(
          name: 'Snake Plant',
          scientificName: 'Sansevieria trifasciata',
          type: PlantType.succulent,
          confidence: 0.89,
          careNotes: [
            'Very low maintenance',
            'Tolerates low light conditions',
            'Water sparingly - every 2-3 weeks',
            'Perfect for beginners',
          ],
        );
      default:
        return PlantIdentificationResult(
          name: 'Peace Lily',
          scientificName: 'Spathiphyllum wallisii',
          type: PlantType.flowering,
          confidence: 0.85,
          careNotes: [
            'Prefers medium, indirect light',
            'Keep soil consistently moist',
            'Brown tips indicate low humidity',
            'Beautiful white flowers when happy',
          ],
        );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _identificationResult = null;
    });
  }

  void _addManually() {
    // Navigate to manual add with the captured image
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AddPlantScreenWithImage(image: _capturedImage),
      ),
    );
  }

  Future<void> _addIdentifiedPlant() async {
    if (_identificationResult == null || _capturedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final plant = Plant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _identificationResult!.name,
        species: _identificationResult!.scientificName,
        location: 'New Location', // User can edit this later
        type: _identificationResult!.type,
        dateAdded: DateTime.now(),
        careSchedule: CareSchedule(
          wateringIntervalDays: _getDefaultWateringInterval(_identificationResult!.type),
          fertilizingIntervalDays: _getDefaultFertilizingInterval(_identificationResult!.type),
          repottingIntervalMonths: 12,
          careNotes: _identificationResult!.careNotes,
        ),
        healthStatus: HealthStatus.good,
        imageUrl: _capturedImage!.path,
        notes: 'Added via plant identification',
      );

      await ref.read(plantsProvider.notifier).addPlant(plant);

      if (mounted) {
        Navigator.of(context).pop(); // Return to plants screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding plant: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

