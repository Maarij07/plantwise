import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme/app_theme.dart';
import '../providers/avatar_provider.dart';
import '../../data/services/avatar_service.dart';

class UnifiedAvatar extends ConsumerWidget {
  final double size;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Widget? fallback;
  final bool showLoadingIndicator;
  final String? customSeed; // Optional custom seed override

  const UnifiedAvatar({
    super.key,
    this.size = 80,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.fallback,
    this.showLoadingIndicator = true,
    this.customSeed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the avatar seed - use custom seed if provided, otherwise use user's current seed
    final userSeed = ref.watch(userAvatarProvider);
    final seed = customSeed ?? userSeed;

    // Generate avatar URL using micah style
    final avatarUrl = AvatarService.generateAvatarUrl(
      seed: seed,
      style: 'micah', // Always use micah style
      size: size.toInt(),
      // No fixed colors - let each seed generate its own unique colors
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        child: SvgPicture.network(
          avatarUrl,
          key: ValueKey('avatar_${seed}_${size.toInt()}'), // Force refresh when seed changes
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => _buildLoadingPlaceholder(),
          errorBuilder: (context, error, stackTrace) => 
              fallback ?? _buildErrorFallback(),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: showLoadingIndicator 
            ? CircularProgressIndicator(
                strokeWidth: size > 50 ? 2 : 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.primary.withOpacity(0.5),
              ),
      ),
    );
  }

  Widget _buildErrorFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}

// Avatar selector widget for choosing different Micah variations
class MicahAvatarSelector extends ConsumerStatefulWidget {
  final String? currentSeed;
  final Function(String)? onAvatarSelected;
  final int optionsCount;

  const MicahAvatarSelector({
    super.key,
    this.currentSeed,
    this.onAvatarSelected,
    this.optionsCount = 6,
  });

  @override
  ConsumerState<MicahAvatarSelector> createState() => _MicahAvatarSelectorState();
}

class _MicahAvatarSelectorState extends ConsumerState<MicahAvatarSelector> {
  List<String> _avatarSeeds = [];
  String? _selectedSeed;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateAvatarOptions();
  }

  void _generateAvatarOptions() {
    setState(() {
      _isLoading = true;
    });

    final userSeed = ref.read(avatarSeedProvider);
    final baseSeed = widget.currentSeed ?? userSeed;
    
    // Generate seeds for each avatar option using Micah style variations
    _avatarSeeds.clear();

    for (int i = 0; i < widget.optionsCount; i++) {
      String seed = '${baseSeed}_micah_$i';
      _avatarSeeds.add(seed);
    }

    _selectedSeed = widget.currentSeed ?? baseSeed;
    
    setState(() {
      _isLoading = false;
    });
  }

  void _selectAvatar(int index) {
    setState(() {
      _selectedSeed = _avatarSeeds[index];
    });
    
    if (widget.onAvatarSelected != null) {
      widget.onAvatarSelected!(_avatarSeeds[index]);
    }
  }

  void _regenerateOptions() {
    _generateAvatarOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Choose Your Micah Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _regenerateOptions,
              icon: const Icon(Icons.refresh),
              tooltip: 'Generate New Options',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _avatarSeeds.length,
            itemBuilder: (context, index) {
              final seed = _avatarSeeds[index];
              final isSelected = _selectedSeed == seed;
              
              return GestureDetector(
                onTap: () => _selectAvatar(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: UnifiedAvatar(
                      customSeed: seed,
                      size: 80,
                      borderRadius: BorderRadius.circular(12),
                      showLoadingIndicator: false,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
