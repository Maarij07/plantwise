import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/plant.dart';
import '../providers/plants_provider.dart';
import 'plant_detail_screen.dart'; // For PlantType color extension

class AddPlantScreen extends ConsumerStatefulWidget {
  final File? preSelectedImage;
  
  const AddPlantScreen({super.key, this.preSelectedImage});

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _careNotesController = TextEditingController();
  
  PlantType _selectedType = PlantType.foliage;
  HealthStatus _selectedHealthStatus = HealthStatus.good;
  int _wateringInterval = 7;
  int _fertilizingInterval = 30;
  int? _repottingInterval = 12;
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Use pre-selected image from camera screen if provided
    if (widget.preSelectedImage != null) {
      _selectedImage = widget.preSelectedImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _careNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _savePlant,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),
              
              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildSpeciesField(),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildPlantTypeDropdown(),
              const SizedBox(height: 16),
              _buildHealthStatusDropdown(),
              const SizedBox(height: 24),
              
              // Care Schedule
              _buildSectionTitle('Care Schedule'),
              const SizedBox(height: 16),
              _buildWateringIntervalField(),
              const SizedBox(height: 16),
              _buildFertilizingIntervalField(),
              const SizedBox(height: 16),
              _buildRepottingIntervalField(),
              const SizedBox(height: 16),
              _buildCareNotesField(),
              const SizedBox(height: 24),
              
              // Additional Notes
              _buildSectionTitle('Additional Notes'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Plant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Plant Photo'),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        Text(
                          'Tap to select',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Photo'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Plant Name *',
        hintText: 'e.g., My Monstera',
        prefixIcon: Icon(Icons.eco),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Plant name is required';
        }
        return null;
      },
    );
  }

  Widget _buildSpeciesField() {
    return TextFormField(
      controller: _speciesController,
      decoration: const InputDecoration(
        labelText: 'Species *',
        hintText: 'e.g., Monstera deliciosa',
        prefixIcon: Icon(Icons.science),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Species is required';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location *',
        hintText: 'e.g., Living Room',
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Location is required';
        }
        return null;
      },
    );
  }

  Widget _buildPlantTypeDropdown() {
    return DropdownButtonFormField<PlantType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Plant Type',
        prefixIcon: Icon(Icons.category),
      ),
      items: PlantType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(type.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (PlantType? value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildHealthStatusDropdown() {
    return DropdownButtonFormField<HealthStatus>(
      value: _selectedHealthStatus,
      decoration: const InputDecoration(
        labelText: 'Health Status',
        prefixIcon: Icon(Icons.favorite),
      ),
      items: HealthStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (HealthStatus? value) {
        if (value != null) {
          setState(() {
            _selectedHealthStatus = value;
          });
        }
      },
    );
  }

  Widget _buildWateringIntervalField() {
    return TextFormField(
      initialValue: _wateringInterval.toString(),
      decoration: const InputDecoration(
        labelText: 'Watering Interval (days) *',
        hintText: 'e.g., 7',
        prefixIcon: Icon(Icons.water_drop),
        suffixText: 'days',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Watering interval is required';
        }
        final interval = int.tryParse(value);
        if (interval == null || interval <= 0) {
          return 'Please enter a valid number of days';
        }
        return null;
      },
      onChanged: (value) {
        final interval = int.tryParse(value);
        if (interval != null) {
          _wateringInterval = interval;
        }
      },
    );
  }

  Widget _buildFertilizingIntervalField() {
    return TextFormField(
      initialValue: _fertilizingInterval.toString(),
      decoration: const InputDecoration(
        labelText: 'Fertilizing Interval (days) *',
        hintText: 'e.g., 30',
        prefixIcon: Icon(Icons.grass),
        suffixText: 'days',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Fertilizing interval is required';
        }
        final interval = int.tryParse(value);
        if (interval == null || interval <= 0) {
          return 'Please enter a valid number of days';
        }
        return null;
      },
      onChanged: (value) {
        final interval = int.tryParse(value);
        if (interval != null) {
          _fertilizingInterval = interval;
        }
      },
    );
  }

  Widget _buildRepottingIntervalField() {
    return TextFormField(
      initialValue: _repottingInterval?.toString() ?? '',
      decoration: const InputDecoration(
        labelText: 'Repotting Interval (months)',
        hintText: 'e.g., 12 (optional)',
        prefixIcon: Icon(Icons.local_florist),
        suffixText: 'months',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final interval = int.tryParse(value);
          if (interval == null || interval <= 0) {
            return 'Please enter a valid number of months';
          }
        }
        return null;
      },
      onChanged: (value) {
        if (value.trim().isEmpty) {
          _repottingInterval = null;
        } else {
          final interval = int.tryParse(value);
          if (interval != null) {
            _repottingInterval = interval;
          }
        }
      },
    );
  }

  Widget _buildCareNotesField() {
    return TextFormField(
      controller: _careNotesController,
      decoration: const InputDecoration(
        labelText: 'Care Notes',
        hintText: 'e.g., Prefers bright indirect light',
        prefixIcon: Icon(Icons.lightbulb_outline),
        helperText: 'Separate multiple notes with commas',
      ),
      maxLines: 3,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Any additional information about your plant...',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _savePlant() async {
    print('_savePlant called');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse care notes
      List<String>? careNotes;
      if (_careNotesController.text.trim().isNotEmpty) {
        careNotes = _careNotesController.text
            .split(',')
            .map((note) => note.trim())
            .where((note) => note.isNotEmpty)
            .toList();
      }

      // Create the plant
      final plant = Plant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        location: _locationController.text.trim(),
        type: _selectedType,
        dateAdded: DateTime.now(),
        careSchedule: CareSchedule(
          wateringIntervalDays: _wateringInterval,
          fertilizingIntervalDays: _fertilizingInterval,
          repottingIntervalMonths: _repottingInterval,
          careNotes: careNotes,
        ),
        healthStatus: _selectedHealthStatus,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        // imageUrl will be set by the Firebase service after Cloudinary upload
      );

      print('Plant object created: ${plant.name}');
      
      // Add the plant with image upload to Firebase/Cloudinary
      await ref.read(plantsProvider.notifier).addPlant(plant, imageFile: _selectedImage);
      print('Plant added to provider successfully');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        print('Success message shown, navigated back');
      }
    } catch (e, stackTrace) {
      print('Error adding plant: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding plant: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

