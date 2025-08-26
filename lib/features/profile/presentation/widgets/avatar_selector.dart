import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/services/avatar_service.dart';
import 'bitmoji_avatar.dart';

class AvatarPickerWidget extends StatefulWidget {
  final String currentSeed;
  final String? gender;
  final Function(String) onAvatarSelected;

  const AvatarPickerWidget({
    super.key,
    required this.currentSeed,
    this.gender,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPickerWidget> createState() => _AvatarPickerWidgetState();
}

class _AvatarPickerWidgetState extends State<AvatarPickerWidget> {
  late String _selectedSeed;
  final String _selectedStyle = 'micah'; // Fixed default style
  final String _selectedGender = 'male'; // Fixed default gender

  // Generate diverse seeds for different avatar appearances
  List<String> get _quickSeeds {
    final baseSeed = widget.currentSeed ?? 'user_avatar';
    return [
      '${baseSeed}_variant_a',
      '${baseSeed}_variant_b', 
      '${baseSeed}_variant_c',
      '${baseSeed}_variant_d',
      '${baseSeed}_variant_e',
      '${baseSeed}_variant_f',
      '${baseSeed}_variant_g',
      '${baseSeed}_variant_h',
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedSeed = widget.currentSeed;
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Avatar Preview
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 50 : 40,
                    backgroundColor: Colors.white,
                    child: BitmojiAvatar(
                      seed: _selectedSeed,
                      style: _selectedStyle,
                      gender: _selectedGender,
                      size: isTablet ? 100 : 80,
                      fallback: Icon(
                        Icons.person,
                        size: isTablet ? 40 : 30,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Avatar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Seed Options
          Text(
            'Quick Picks',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _quickSeeds.length,
            itemBuilder: (context, index) {
              final seed = _quickSeeds[index];
              final isSelected = _selectedSeed == seed;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeed = seed;
                  });
                  widget.onAvatarSelected(_selectedSeed);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: BitmojiAvatar(
                        seed: seed,
                        style: _selectedStyle,
                        gender: _selectedGender,
                        size: isTablet ? 60 : 50,
                        fallback: Icon(
                          Icons.person,
                          size: isTablet ? 30 : 25,
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
