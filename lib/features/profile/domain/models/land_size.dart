import 'package:freezed_annotation/freezed_annotation.dart';

part 'land_size.freezed.dart';
part 'land_size.g.dart';

@freezed
class LandSize with _$LandSize {
  const factory LandSize({
    required double value,
    required String unit,
  }) = _LandSize;

  factory LandSize.fromJson(Map<String, dynamic> json) =>
      _$LandSizeFromJson(json);
}

enum LandUnit {
  squareMeters('m²', 'Square Meters', 1.0, 100000.0),
  squareFeet('ft²', 'Square Feet', 1.0, 100000.0),
  acres('ac', 'Acres', 0.1, 100.0),
  hectares('ha', 'Hectares', 0.1, 100.0);

  const LandUnit(this.symbol, this.displayName, this.minValue, this.maxValue);

  final String symbol;
  final String displayName;
  final double minValue;
  final double maxValue;

  static LandUnit fromSymbol(String symbol) {
    return values.firstWhere(
      (unit) => unit.symbol == symbol,
      orElse: () => squareMeters,
    );
  }
}
