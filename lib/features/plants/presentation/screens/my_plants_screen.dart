import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/plant_image_service.dart';
import '../../domain/models/plant.dart';
import '../providers/plants_provider.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';
import 'camera_plant_screen.dart';

class MyPlantsScreen extends ConsumerStatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  ConsumerState<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends ConsumerState<MyPlantsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PlantType? _selectedTypeFilter;
  HealthStatus? _selectedHealthFilter;
  String _sortBy = 'name'; // name, date, health
  bool _isGridView = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncPlants = ref.watch(plantsProvider);
    final asyncPlantsNeedingWater = ref.watch(plantsNeedingWaterProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildEnhancedAppBar(context, isTablet),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: asyncPlants.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(context, error.toString()),
            data: (plants) {
              final filteredPlants = _getFilteredAndSortedPlants(plants);
              if (filteredPlants.isEmpty && _searchQuery.isNotEmpty) {
                return _buildNoResultsState(context);
              }
              if (plants.isEmpty) {
                return _buildEnhancedEmptyState(context, isTablet);
              }
              return asyncPlantsNeedingWater.when(
                loading: () => _buildMainContent(context, plants, filteredPlants, [], isTablet, isLargeScreen),
                error: (error, stack) => _buildMainContent(context, plants, filteredPlants, [], isTablet, isLargeScreen),
                data: (plantsNeedingWater) => _buildMainContent(context, plants, filteredPlants, plantsNeedingWater, isTablet, isLargeScreen),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(context, isTablet),
    );
  }



  void _showAddPlantOptions(BuildContext context) {
    print('_showAddPlantOptions called');
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
                print('Take Photo option tapped');
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
                print('Add Manually option tapped');
                Navigator.pop(context);
                print('Navigating to AddPlantScreen...');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddPlantScreen(),
                  ),
                );
                print('Navigation call completed');
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
                leading: Icon(Icons.water_drop, color: AppColors.info),
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


// Enhanced UI Methods for My Plants Screen
extension _MyPlantsScreenMethods on _MyPlantsScreenState {
  
  // Enhanced App Bar
  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'My Plants',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontSize: isTablet ? 28 : 24,
        ),
      ),
      actions: [
        // Search Button
        Container(
          margin: EdgeInsets.only(right: isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.primary,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () => _showEnhancedSearchDialog(context),
          ),
        ),
        // Filter Button
        Container(
          margin: EdgeInsets.only(right: isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune,
              color: AppColors.secondary,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () => _showFilterDialog(context),
          ),
        ),
        // View Toggle Button
        Container(
          margin: EdgeInsets.only(right: isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.info,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ),
      ],
    );
  }

  // Enhanced Empty State
  Widget _buildEnhancedEmptyState(BuildContext context, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration
            Container(
              width: isTablet ? 180 : 140,
              height: isTablet ? 180 : 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 90 : 70),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.eco_outlined,
                size: isTablet ? 80 : 60,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            Text(
              'No plants yet!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 28 : 24,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Start your green journey by adding your first plant.\nYou can take a photo to identify it automatically!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
                fontSize: isTablet ? 18 : 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 40 : 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPlantOptions(context),
                    icon: Icon(Icons.add, size: isTablet ? 24 : 20),
                    label: Text(
                      'Add Plant',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 24,
                        vertical: isTablet ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  // Error State
  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry loading plants
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // No Results State
  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.grey300.withOpacity(0.5),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.search_off,
                size: 60,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No plants found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters to find what you\'re looking for.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedTypeFilter = null;
                  _selectedHealthFilter = null;
                  _searchController.clear();
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  // Main Content Layout
  Widget _buildMainContent(
    BuildContext context,
    List<Plant> plants,
    List<Plant> filteredPlants,
    List<Plant> plantsNeedingWater,
    bool isTablet,
    bool isLargeScreen,
  ) {
    final horizontalPadding = isLargeScreen ? 32.0 : isTablet ? 24.0 : 16.0;
    
    return CustomScrollView(
      slivers: [
        // Search Bar
        if (_searchQuery.isNotEmpty || _selectedTypeFilter != null || _selectedHealthFilter != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: _buildActiveFiltersChips(context),
            ),
          ),
            
        // Care Alert
        if (plantsNeedingWater.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: _buildEnhancedCareAlert(context, plantsNeedingWater, isTablet),
            ),
          ),
            
        // Quick Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child: _buildEnhancedStatsCards(plants, isTablet),
          ),
        ),
        
        // Plants Header with Sort Options
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: _buildPlantsHeader(context, filteredPlants, isTablet),
          ),
        ),
        
        // Plants Grid/List
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _isGridView
                ? _buildEnhancedPlantsGrid(filteredPlants, isTablet, isLargeScreen)
                : _buildPlantsList(filteredPlants, isTablet),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Enhanced FAB
  Widget _buildEnhancedFAB(BuildContext context, bool isTablet) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddPlantOptions(context),
      backgroundColor: AppColors.primary,
      icon: Icon(
        Icons.add,
        size: isTablet ? 24 : 20,
      ),
      label: Text(
        'Add Plant',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // Filter and Sort Methods
  List<Plant> _getFilteredAndSortedPlants(List<Plant> plants) {
    var filtered = plants.where((plant) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!plant.name.toLowerCase().contains(query) &&
            !plant.species.toLowerCase().contains(query) &&
            !plant.location.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Type filter
      if (_selectedTypeFilter != null && plant.type != _selectedTypeFilter) {
        return false;
      }
      
      // Health filter
      if (_selectedHealthFilter != null && plant.healthStatus != _selectedHealthFilter) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'health':
        filtered.sort((a, b) {
          final aHealth = a.healthStatus?.index ?? -1;
          final bHealth = b.healthStatus?.index ?? -1;
          return aHealth.compareTo(bHealth);
        });
        break;
    }
    
    return filtered;
  }

  // Enhanced Search Dialog
  void _showEnhancedSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Plants'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name, species, or location...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // Filter Dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Plants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plant Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PlantType.values.map((type) {
                return FilterChip(
                  label: Text(type.displayName),
                  selected: _selectedTypeFilter == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeFilter = selected ? type : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Health Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: HealthStatus.values.map((status) {
                return FilterChip(
                  label: Text(status.displayName),
                  selected: _selectedHealthFilter == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedHealthFilter = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTypeFilter = null;
                _selectedHealthFilter = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // Active Filters Chips
  Widget _buildActiveFiltersChips(BuildContext context) {
    final chips = <Widget>[];
    
    if (_searchQuery.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Search: $_searchQuery'),
          onDeleted: () {
            setState(() {
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      );
    }
    
    if (_selectedTypeFilter != null) {
      chips.add(
        Chip(
          label: Text('Type: ${_selectedTypeFilter!.displayName}'),
          onDeleted: () {
            setState(() {
              _selectedTypeFilter = null;
            });
          },
        ),
      );
    }
    
    if (_selectedHealthFilter != null) {
      chips.add(
        Chip(
          label: Text('Health: ${_selectedHealthFilter!.displayName}'),
          onDeleted: () {
            setState(() {
              _selectedHealthFilter = null;
            });
          },
        ),
      );
    }
    
    if (chips.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Filters:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chips,
          ),
        ],
      ),
    );
  }

  // Enhanced Care Alert
  Widget _buildEnhancedCareAlert(BuildContext context, List<Plant> plantsNeedingWater, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            ),
            child: Icon(
              Icons.water_drop,
              color: AppColors.warning,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plants need water! 💧',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  '${plantsNeedingWater.length} plant${plantsNeedingWater.length > 1 ? 's' : ''} ${plantsNeedingWater.length == 1 ? 'needs' : 'need'} watering',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showCareTasksDialog(context, plantsNeedingWater),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'View',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Stats Cards
  Widget _buildEnhancedStatsCards(List<Plant> plants, bool isTablet) {
    final healthyPlants = plants.where((p) => 
        p.healthStatus == HealthStatus.excellent || 
        p.healthStatus == HealthStatus.good).length;
    
    final plantsNeedingCare = plants.where((p) {
      final daysSinceWatered = p.lastWatered != null
          ? DateTime.now().difference(p.lastWatered!).inDays
          : null;
      return daysSinceWatered != null && 
             daysSinceWatered >= p.careSchedule.wateringIntervalDays;
    }).length;
    
    final plantsAddedThisMonth = plants.where((p) {
      final now = DateTime.now();
      return p.dateAdded.month == now.month && p.dateAdded.year == now.year;
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        if (screenWidth < 300) {
          return Column(
            children: [
              _buildEnhancedStatCard(
                context,
                title: 'Total Plants',
                value: plants.length.toString(),
                icon: Icons.eco,
                color: AppColors.primary,
                subtitle: 'in your collection',
                isTablet: isTablet,
                isCompact: true,
              ),
              const SizedBox(height: 12),
              _buildEnhancedStatCard(
                context,
                title: 'Healthy Plants',
                value: healthyPlants.toString(),
                icon: Icons.favorite,
                color: AppColors.success,
                subtitle: 'thriving well',
                isTablet: isTablet,
                isCompact: true,
              ),
              const SizedBox(height: 12),
              _buildEnhancedStatCard(
                context,
                title: 'Need Care',
                value: plantsNeedingCare.toString(),
                icon: Icons.water_drop,
                color: AppColors.warning,
                subtitle: 'require attention',
                isTablet: isTablet,
                isCompact: true,
              ),
            ],
          );
        } else if (screenWidth < 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      title: 'Total Plants',
                      value: plants.length.toString(),
                      icon: Icons.eco,
                      color: AppColors.primary,
                      subtitle: 'in collection',
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      title: 'Healthy',
                      value: healthyPlants.toString(),
                      icon: Icons.favorite,
                      color: AppColors.success,
                      subtitle: 'thriving',
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedStatCard(
                      context,
                      title: 'Need Care',
                      value: plantsNeedingCare.toString(),
                      icon: Icons.water_drop,
                      color: AppColors.warning,
                      subtitle: 'attention needed',
                      isTablet: isTablet,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          );
        }
        
        return Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Total Plants',
                value: plants.length.toString(),
                icon: Icons.eco,
                color: AppColors.primary,
                subtitle: 'in your collection',
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Healthy Plants',
                value: healthyPlants.toString(),
                icon: Icons.favorite,
                color: AppColors.success,
                subtitle: 'thriving well',
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                context,
                title: 'Need Care',
                value: plantsNeedingCare.toString(),
                icon: Icons.water_drop,
                color: AppColors.warning,
                subtitle: 'require attention',
                isTablet: isTablet,
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced Stat Card
  Widget _buildEnhancedStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required bool isTablet,
    bool isCompact = false,
  }) {
    if (isCompact) {
      return Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: isTablet ? 24 : 20,
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet ? 24 : 20,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isTablet ? 32 : 28,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  // Plants Header with Sort
  Widget _buildPlantsHeader(BuildContext context, List<Plant> filteredPlants, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Plants (${filteredPlants.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _sortBy = value;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'name',
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha,
                    color: _sortBy == 'name' ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Name',
                    style: TextStyle(
                      color: _sortBy == 'name' ? AppColors.primary : null,
                      fontWeight: _sortBy == 'name' ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'date',
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: _sortBy == 'date' ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date Added',
                    style: TextStyle(
                      color: _sortBy == 'date' ? AppColors.primary : null,
                      fontWeight: _sortBy == 'date' ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'health',
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: _sortBy == 'health' ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Health Status',
                    style: TextStyle(
                      color: _sortBy == 'health' ? AppColors.primary : null,
                      fontWeight: _sortBy == 'health' ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  color: AppColors.primary,
                  size: isTablet ? 20 : 16,
                ),
                SizedBox(width: isTablet ? 8 : 6),
                Text(
                  'Sort',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced Plants Grid
  Widget _buildEnhancedPlantsGrid(List<Plant> plants, bool isTablet, bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        double spacing;
        
        if (isLargeScreen) {
          crossAxisCount = 4;
          childAspectRatio = 0.85;
          spacing = 20;
        } else if (isTablet) {
          crossAxisCount = 3;
          childAspectRatio = 0.9;
          spacing = 16;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 2;
          childAspectRatio = 0.95;
          spacing = 16;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.2;
          spacing = 12;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) => _EnhancedPlantCard(
            plant: plants[index],
            isTablet: isTablet,
          ),
        );
      },
    );
  }

  // Plants List View
  Widget _buildPlantsList(List<Plant> plants, bool isTablet) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plants.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        child: _EnhancedPlantListItem(
          plant: plants[index],
          isTablet: isTablet,
        ),
      ),
    );
  }
}

// Enhanced Plant Card Widget
class _EnhancedPlantCard extends StatelessWidget {
  final Plant plant;
  final bool isTablet;

  const _EnhancedPlantCard({
    required this.plant,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceWatered = plant.lastWatered != null
        ? DateTime.now().difference(plant.lastWatered!).inDays
        : null;

    final needsWater = daysSinceWatered != null &&
        daysSinceWatered >= plant.careSchedule.wateringIntervalDays;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlantDetailScreen(plant: plant),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant Image with enhanced indicators
                Stack(
                  children: [
                    Container(
                      height: isTablet ? 160 : 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildPlantImage(),
                      ),
                    ),
                    
                    // Health status indicator
                    if (plant.healthStatus != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: isTablet ? 16 : 14,
                          height: isTablet ? 16 : 14,
                          decoration: BoxDecoration(
                            color: plant.healthStatus!.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: plant.healthStatus!.color.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Water need indicator
                    if (needsWater)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: isTablet ? 12 : 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: isTablet ? 4 : 2),
                              Text(
                                'Water',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Plant type badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              plant.type.icon,
                              size: isTablet ? 14 : 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: isTablet ? 4 : 2),
                            Text(
                              plant.type.displayName,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                // Plant information
                Text(
                  plant.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                    fontSize: isTablet ? 18 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: isTablet ? 6 : 4),
                
                Text(
                  plant.species,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                    fontSize: isTablet ? 14 : 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: isTablet ? 8 : 6),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isTablet ? 16 : 14,
                      color: AppColors.grey500,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Expanded(
                      child: Text(
                        plant.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 14 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                if (daysSinceWatered != null) ...[
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: isTablet ? 16 : 14,
                        color: needsWater ? AppColors.warning : AppColors.grey400,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        'Watered ${daysSinceWatered}d ago',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: needsWater ? AppColors.warning : AppColors.grey400,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantIcon() {
    return Center(
      child: Container(
        width: isTablet ? 100 : 80,
        height: isTablet ? 100 : 80,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 50 : 40),
        ),
        child: Icon(
          plant.type.icon,
          size: isTablet ? 50 : 40,
          color: AppColors.primary.withOpacity(0.7),
        ),
      ),
    );
  }
  
  Widget _buildPlantImage() {
    // Get optimized image URL using the PlantImageService
    final imageUrl = PlantImageService.instance.getPlantImageUrl(
      plant,
      size: ImageSize.card,
    );
    
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: AppColors.grey200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlantIcon(),
      );
    } else {
      try {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlantIcon(),
        );
      } catch (e) {
        return _buildPlantIcon();
      }
    }
  }
}

// Enhanced Plant List Item Widget
class _EnhancedPlantListItem extends StatelessWidget {
  final Plant plant;
  final bool isTablet;

  const _EnhancedPlantListItem({
    required this.plant,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceWatered = plant.lastWatered != null
        ? DateTime.now().difference(plant.lastWatered!).inDays
        : null;

    final needsWater = daysSinceWatered != null &&
        daysSinceWatered >= plant.careSchedule.wateringIntervalDays;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlantDetailScreen(plant: plant),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                // Plant Image
                Container(
                  width: isTablet ? 80 : 60,
                  height: isTablet ? 80 : 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: plant.imageUrl != null
                        ? _buildPlantImage()
                        : _buildPlantIcon(),
                  ),
                ),
                
                SizedBox(width: isTablet ? 20 : 16),
                
                // Plant Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plant.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 18 : 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (plant.healthStatus != null)
                            Container(
                              width: isTablet ? 12 : 10,
                              height: isTablet ? 12 : 10,
                              decoration: BoxDecoration(
                                color: plant.healthStatus!.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: isTablet ? 6 : 4),
                      
                      Text(
                        plant.species,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                          fontSize: isTablet ? 14 : 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: isTablet ? 8 : 6),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isTablet ? 16 : 14,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            plant.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey500,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            plant.type.icon,
                            size: isTablet ? 16 : 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            plant.type.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                      
                      if (needsWater) ...[
                        SizedBox(height: isTablet ? 8 : 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 10 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: isTablet ? 14 : 12,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: isTablet ? 6 : 4),
                              Text(
                                'Needs watering',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(width: isTablet ? 16 : 12),
                
                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Quick water action
                      },
                      icon: Icon(
                        Icons.water_drop,
                        color: needsWater ? AppColors.warning : AppColors.info,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.grey400,
                      size: isTablet ? 24 : 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantIcon() {
    return Center(
      child: Icon(
        plant.type.icon,
        size: isTablet ? 32 : 24,
        color: AppColors.primary.withOpacity(0.7),
      ),
    );
  }
  
  Widget _buildPlantImage() {
    // Get optimized image URL using the PlantImageService
    final imageUrl = PlantImageService.instance.getPlantImageUrl(
      plant,
      size: ImageSize.thumbnail,
    );
    
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: AppColors.grey200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlantIcon(),
      );
    } else {
      try {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlantIcon(),
        );
      } catch (e) {
        return _buildPlantIcon();
      }
    }
  }
}

