import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/plant.dart';
import '../providers/plants_provider.dart';
import 'edit_plant_screen.dart';

class PlantDetailScreen extends ConsumerWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysSinceWatered = plant.lastWatered != null
        ? DateTime.now().difference(plant.lastWatered!).inDays
        : null;
    
    final daysSinceFertilized = plant.lastFertilized != null
        ? DateTime.now().difference(plant.lastFertilized!).inDays
        : null;

    final needsWater = daysSinceWatered != null && 
        daysSinceWatered >= plant.careSchedule.wateringIntervalDays;
    
    final needsFertilizer = daysSinceFertilized != null &&
        daysSinceFertilized >= plant.careSchedule.fertilizingIntervalDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditPlantDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Image Section
            _buildImageSection(),
            
            // Plant Info Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(context),
                  const SizedBox(height: 24),
                  
                  // Care Status Cards
                  _buildCareStatusSection(context, needsWater, needsFertilizer, daysSinceWatered, daysSinceFertilized),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(context, ref),
                  const SizedBox(height: 24),
                  
                  // Care Schedule Section
                  _buildCareScheduleSection(context),
                  const SizedBox(height: 24),
                  
                  // Notes Section
                  if (plant.notes != null && plant.notes!.isNotEmpty)
                    _buildNotesSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: plant.imageUrl != null
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: _buildPlantImage(),
            )
          : _buildPlantIcon(),
    );
  }

  Widget _buildPlantImage() {
    final imageUrl = plant.imageUrl!;
    
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlantIcon(),
      );
    } else {
      try {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlantIcon(),
        );
      } catch (e) {
        return _buildPlantIcon();
      }
    }
  }

  Widget _buildPlantIcon() {
    return Center(
      child: Icon(
        plant.type.icon,
        size: 120,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.species,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.grey600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (plant.healthStatus != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plant.healthStatus!.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: plant.healthStatus!.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: plant.healthStatus!.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plant.healthStatus!.displayName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: plant.healthStatus!.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.grey600),
            const SizedBox(width: 4),
            Text(
              plant.location,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: plant.type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(plant.type.icon, size: 14, color: plant.type.color),
                  const SizedBox(width: 4),
                  Text(
                    plant.type.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: plant.type.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareStatusSection(BuildContext context, bool needsWater, bool needsFertilizer, int? daysSinceWatered, int? daysSinceFertilized) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CareStatusCard(
                title: 'Watering',
                icon: Icons.water_drop,
                status: needsWater ? 'Needs Water' : 'Well Watered',
                color: needsWater ? AppColors.warning : AppColors.success,
                subtitle: daysSinceWatered != null 
                    ? '${daysSinceWatered} days ago'
                    : 'Never watered',
                isUrgent: needsWater,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CareStatusCard(
                title: 'Fertilizing',
                icon: Icons.grass,
                status: needsFertilizer ? 'Needs Fertilizer' : 'Well Fed',
                color: needsFertilizer ? AppColors.warning : AppColors.success,
                subtitle: daysSinceFertilized != null 
                    ? '${daysSinceFertilized} days ago'
                    : 'Never fertilized',
                isUrgent: needsFertilizer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
              onPressed: () => _markAsWatered(context, ref),
                icon: const Icon(Icons.water_drop, size: 18),
                label: const Text('Water'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
              onPressed: () => _markAsFertilized(context, ref),
                icon: const Icon(Icons.eco, size: 18),
                label: const Text('Fertilize'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
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

  Widget _buildCareScheduleSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildScheduleItem(
              context,
              Icons.water_drop,
              'Watering',
              'Every ${plant.careSchedule.wateringIntervalDays} days',
              AppColors.primary,
            ),
            _buildScheduleItem(
              context,
              Icons.grass,
              'Fertilizing',
              'Every ${plant.careSchedule.fertilizingIntervalDays} days',
              AppColors.secondary,
            ),
            if (plant.careSchedule.repottingIntervalMonths != null)
              _buildScheduleItem(
                context,
                Icons.local_florist,
                'Repotting',
                'Every ${plant.careSchedule.repottingIntervalMonths} months',
                AppColors.warning,
              ),
            if (plant.careSchedule.careNotes != null && plant.careSchedule.careNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Care Notes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...plant.careSchedule.careNotes!.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '• $note',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, IconData icon, String title, String schedule, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  schedule,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plant.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _markAsWatered(BuildContext context, WidgetRef ref) {
    ref.read(plantsProvider.notifier).waterPlant(plant.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plant.name} watered successfully!'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAsFertilized(BuildContext context, WidgetRef ref) {
    ref.read(plantsProvider.notifier).fertilizePlant(plant.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plant.name} fertilized successfully!'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditPlantDialog(BuildContext context) async {
    final updatedPlant = await Navigator.of(context).push<Plant>(
      MaterialPageRoute(
        builder: (context) => EditPlantScreen(plant: plant),
      ),
    );
    
    // The UI will automatically refresh via Riverpod when the plant is updated
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete "${plant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deletePlant(context, ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePlant(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(plantsProvider.notifier).removePlant(plant.id);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Go back to plants list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${plant.name}" deleted successfully'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting plant: $e'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _CareStatusCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String status;
  final String subtitle;
  final Color color;
  final bool isUrgent;

  const _CareStatusCard({
    required this.title,
    required this.icon,
    required this.status,
    required this.subtitle,
    required this.color,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUrgent ? color.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add color to PlantType
extension PlantTypeColorExtension on PlantType {
  Color get color {
    switch (this) {
      case PlantType.flowering:
        return const Color(0xFFE91E63);
      case PlantType.foliage:
        return const Color(0xFF4CAF50);
      case PlantType.succulent:
        return const Color(0xFF8BC34A);
      case PlantType.herb:
        return const Color(0xFF2E7D32);
      case PlantType.tree:
        return const Color(0xFF795548);
      case PlantType.vegetable:
        return const Color(0xFF8BC34A);
      case PlantType.fruit:
        return const Color(0xFFFF9800);
    }
  }
}
