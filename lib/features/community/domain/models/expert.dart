import 'package:freezed_annotation/freezed_annotation.dart';

part 'expert.freezed.dart';
part 'expert.g.dart';

@freezed
class Expert with _$Expert {
  const factory Expert({
    required String id,
    required String userId,
    required String name,
    required String email,
    required String specialty,
    required String bio,
    @Default([]) List<String> credentials,
    @Default(4.0) double rating, // Dummy rating for now
    @Default(0) int followers, // Dummy followers for now
    String? avatar,
    DateTime? approvedAt,
  }) = _Expert;

  factory Expert.fromJson(Map<String, dynamic> json) => _$ExpertFromJson(json);
  
  /// Convert from ExpertApplication to Expert (for approved applications)
  factory Expert.fromApplication({
    required String applicationId,
    required String userId,
    required String userName,
    required String userEmail,
    required String specialty,
    required String bio,
    required List<String> credentials,
    String? avatar,
    DateTime? approvedAt,
  }) {
    // Generate dummy rating between 4.0 and 5.0
    final rating = 4.0 + (userId.hashCode % 100) / 100.0;
    
    // Generate dummy followers between 50 and 10000
    final followers = 50 + (userId.hashCode % 9950);
    
    return Expert(
      id: applicationId,
      userId: userId,
      name: userName,
      email: userEmail,
      specialty: specialty,
      bio: bio,
      credentials: credentials,
      rating: double.parse(rating.toStringAsFixed(1)),
      followers: followers,
      avatar: avatar,
      approvedAt: approvedAt,
    );
  }
}
