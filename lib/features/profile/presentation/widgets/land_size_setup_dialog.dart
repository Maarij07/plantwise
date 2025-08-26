import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/domain/models/land_size.dart';
import '../providers/land_size_provider.dart';

class LandSizeSetupDialog extends ConsumerStatefulWidget {
  const LandSizeSetupDialog({super.key});

  @override
  ConsumerState<LandSizeSetupDialog> createState() => _LandSizeSetupDialogState();
}

class _LandSizeSetupDialogState extends ConsumerState<LandSizeSetupDialog> {
  final TextEditingController _controller = TextEditingController();
  LandUnit _selectedUnit = LandUnit.squareMeters;
  double _currentValue = 100.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // We'll load existing land size after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingLandSize();
    });
    _controller.text = _currentValue.toStringAsFixed(0);
  }
  
  void _loadExistingLandSize() {
    final currentLandSize = ref.read(landSizeProvider);
    if (currentLandSize != null) {
      setState(() {
        // Load existing values
        _currentValue = currentLandSize.value;
        _selectedUnit = LandUnit.values.firstWhere(
          (unit) => unit.symbol == currentLandSize.unit,
          orElse: () => LandUnit.squareMeters,
        );
        _controller.text = _currentValue.toStringAsFixed(0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged(double value) {
      setState(() {
        _currentValue = value.clamp(_selectedUnit.minValue, _selectedUnit.maxValue);
        _controller.text = _currentValue.toStringAsFixed(0);
      });
  }

  void _onTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      setState(() {
        _currentValue = parsed.clamp(_selectedUnit.minValue, _selectedUnit.maxValue);
      });
    }
  }

  void _onUnitChanged(LandUnit? newUnit) {
    if (newUnit != null && newUnit != _selectedUnit) {
      setState(() {
        // Convert current value to new unit
        final oldUnit = _selectedUnit;
        _selectedUnit = newUnit;
        
        // Simple conversion logic (you can expand this for more precise conversions)
        if (oldUnit == LandUnit.squareMeters && newUnit == LandUnit.squareFeet) {
          _currentValue = _currentValue * 10.764;
        } else if (oldUnit == LandUnit.squareFeet && newUnit == LandUnit.squareMeters) {
          _currentValue = _currentValue / 10.764;
        } else if (oldUnit == LandUnit.squareMeters && newUnit == LandUnit.acres) {
          _currentValue = _currentValue / 4047;
        } else if (oldUnit == LandUnit.acres && newUnit == LandUnit.squareMeters) {
          _currentValue = _currentValue * 4047;
        } else if (oldUnit == LandUnit.squareMeters && newUnit == LandUnit.hectares) {
          _currentValue = _currentValue / 10000;
        } else if (oldUnit == LandUnit.hectares && newUnit == LandUnit.squareMeters) {
          _currentValue = _currentValue * 10000;
        }
        
        _currentValue = _currentValue.clamp(_selectedUnit.minValue, _selectedUnit.maxValue);
        _controller.text = _currentValue.toStringAsFixed(0);
      });
    }
  }

  Future<void> _saveLandSize() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(landSizeProvider.notifier).setLandSize(_currentValue, _selectedUnit);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Land size saved successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving land size: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Setup Land Size',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your garden or farm to get personalized recommendations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Unit Selector
            Text(
              'Unit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<LandUnit>(
              value: _selectedUnit,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: LandUnit.values.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(
                    unit.displayName,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: _onUnitChanged,
            ),
            const SizedBox(height: 20),
            
            // Size Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixText: _selectedUnit.symbol,
                        ),
                        onChanged: _onTextChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjust with slider',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF2E7D32),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFF2E7D32),
                    overlayColor: const Color(0xFF2E7D32).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: _selectedUnit.minValue,
                    max: _selectedUnit.maxValue,
                    divisions: (_selectedUnit.maxValue - _selectedUnit.minValue).round(),
                    onChanged: _onValueChanged,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedUnit.minValue.toStringAsFixed(0)} ${_selectedUnit.symbol}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${_selectedUnit.maxValue.toStringAsFixed(0)} ${_selectedUnit.symbol}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveLandSize,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
