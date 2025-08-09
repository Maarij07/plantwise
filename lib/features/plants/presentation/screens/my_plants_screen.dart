import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/plant.dart';
import '../providers/plants_provider.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';
import 'camera_plant_screen.dart';

class MyPlantsScreen extends ConsumerWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final plantsNeedingWater = ref.watch(plantsNeedingWaterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPlantOptions(context),
          ),
        ],
      ),
      body: plants.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plantsNeedingWater.isNotEmpty) ...[
                    _buildCareAlert(context, plantsNeedingWater),
                    const SizedBox(height: 24),
                  ],
                  _buildStatsCards(plants),
                  const SizedBox(height: 24),
                  Text(
                    'Your Plants (${plants.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlantsGrid(plants),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.eco_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No plants yet!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your plant journey by adding your first plant.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPlantOptions(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Plant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareAlert(BuildContext context, List<Plant> plantsNeedingWater) {
    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plants need water!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    '${plantsNeedingWater.length} plant${plantsNeedingWater.length > 1 ? 's' : ''} need${plantsNeedingWater.length == 1 ? 's' : ''} watering',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showCareTasksDialog(context, plantsNeedingWater),
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<Plant> plants) {
    final healthyPlants = plants.where((p) => 
        p.healthStatus == HealthStatus.excellent || 
        p.healthStatus == HealthStatus.good).length;
    
    final plantsAddedThisMonth = plants.where((p) {
      final now = DateTime.now();
      return p.dateAdded.month == now.month && p.dateAdded.year == now.year;
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          // Stack cards vertically on very small screens
          return Column(
            children: [
              _StatCard(
                title: 'Total Plants',
                value: plants.length.toString(),
                icon: Icons.eco,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'Healthy',
                value: healthyPlants.toString(),
                icon: Icons.favorite,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: 'New This Month',
                value: plantsAddedThisMonth.toString(),
                icon: Icons.calendar_today,
                color: AppColors.secondary,
              ),
            ],
          );
        }
        
        // Default horizontal layout for larger screens
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Plants',
                  value: plants.length.toString(),
                  icon: Icons.eco,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Healthy',
                  value: healthyPlants.toString(),
                  icon: Icons.favorite,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'New This Month',
                  value: plantsAddedThisMonth.toString(),
                  icon: Icons.calendar_today,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlantsGrid(List<Plant> plants) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 600) {
          // Large screens (tablets)
          crossAxisCount = 3;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 400) {
          // Medium screens
          crossAxisCount = 2;
          childAspectRatio = 0.8;
        } else {
          // Small screens
          crossAxisCount = 1;
          childAspectRatio = 1.2;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) => _PlantCard(plant: plants[index]),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality coming soon!')),
    );
  }

  void _showAddPlantOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add New Plant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.add_photo_alternate, color: AppColors.primary),
              title: const Text('Take Photo'),
              subtitle: const Text('Identify plant from photo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CameraPlantScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Add Manually'),
              subtitle: const Text('Enter plant details yourself'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddPlantScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCareTasksDialog(BuildContext context, List<Plant> plants) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Care Tasks'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return ListTile(
                leading: Icon(Icons.water_drop, color: plant.type.color),
                title: Text(plant.name),
                subtitle: Text('${plant.location} • Water needed'),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    // TODO: Mark as watered
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    final daysSinceWatered = plant.lastWatered != null
        ? DateTime.now().difference(plant.lastWatered!).inDays
        : null;

    final needsWater = daysSinceWatered != null &&
        daysSinceWatered >= plant.careSchedule.wateringIntervalDays;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plant: plant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Image/Icon
            Container(
              height: 120,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              child: plant.imageUrl != null
                  ? _buildPlantImage()
                  : _buildPlantIcon(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant name and health status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plant.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (plant.healthStatus != null)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: plant.healthStatus!.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Care status
                  if (needsWater)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Needs water',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantIcon() {
    return Icon(
      plant.type.icon,
      size: 60,
      color: AppColors.primary.withOpacity(0.5),
    );
  }
  
  Widget _buildPlantImage() {
    final imageUrl = plant.imageUrl!;
    
    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http')) {
      // Network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlantIcon(),
      );
    } else {
      // Local file path - handle as File
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
}

