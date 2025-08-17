import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/services/avatar_service.dart';

class BitmojiAvatar extends StatelessWidget {
  final String? seed;
  final String? gender;
  final double size;
  final String? style;
  final Map<String, dynamic>? customOptions;
  final Widget? fallback;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const BitmojiAvatar({
    super.key,
    this.seed,
    this.gender,
    this.size = 80,
    this.style,
    this.customOptions,
    this.fallback,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = AvatarService.generateAvatarUrl(
      seed: seed,
      gender: gender,
      style: style,
      size: size.toInt(),
      customOptions: customOptions,
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}

class AvatarSelector extends StatefulWidget {
  final String? gender;
  final String? currentSeed;
  final Function(String)? onAvatarSelected;
  final int optionsCount;

  const AvatarSelector({
    super.key,
    this.gender,
    this.currentSeed,
    this.onAvatarSelected,
    this.optionsCount = 6,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  List<String> _avatarUrls = [];
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

    // Generate seeds for each avatar option
    _avatarSeeds.clear();
    _avatarUrls.clear();

    for (int i = 0; i < widget.optionsCount; i++) {
      String seed = widget.currentSeed != null 
          ? '${widget.currentSeed}_option_$i' 
          : 'option_${DateTime.now().millisecondsSinceEpoch}_$i';
      
      _avatarSeeds.add(seed);
      _avatarUrls.add(
        AvatarService.generateAvatarUrl(
          seed: seed,
          gender: widget.gender,
          size: 120,
        ),
      );
    }

    _selectedSeed = widget.currentSeed;
    
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
              'Choose Your Avatar',
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
            ),
            itemCount: _avatarUrls.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedSeed == _avatarSeeds[index];
              
              return GestureDetector(
                onTap: () => _selectAvatar(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SvgPicture.network(
                      _avatarUrls[index],
                      fit: BoxFit.cover,
                      placeholderBuilder: (context) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                        ),
                      ),
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
