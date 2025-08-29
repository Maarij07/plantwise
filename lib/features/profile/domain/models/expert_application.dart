import 'package:freezed_annotation/freezed_annotation.dart';

part 'expert_application.freezed.dart';
part 'expert_application.g.dart';

@freezed
class ExpertApplication with _$ExpertApplication {
  const factory ExpertApplication({
    String? id, // Firestore document ID
    required String userId,
    required String userEmail,
    required String userName,
    required String specialty,
    required String experience,
    required String bio,
    @Default([]) List<String> credentials,
    @Default(ExpertApplicationStatus.pending) ExpertApplicationStatus status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewNotes,
    String? reviewedBy,
  }) = _ExpertApplication;

  factory ExpertApplication.fromJson(Map<String, dynamic> json) =>
      _$ExpertApplicationFromJson(json);
}

@JsonEnum()
enum ExpertApplicationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('under_review')
  underReview,
}

extension ExpertApplicationStatusX on ExpertApplicationStatus {
  String get displayName {
    switch (this) {
      case ExpertApplicationStatus.pending:
        return 'Pending Review';
      case ExpertApplicationStatus.approved:
        return 'Approved';
      case ExpertApplicationStatus.rejected:
        return 'Rejected';
      case ExpertApplicationStatus.underReview:
        return 'Under Review';
    }
  }

  String get description {
    switch (this) {
      case ExpertApplicationStatus.pending:
        return 'Your application is waiting to be reviewed';
      case ExpertApplicationStatus.approved:
        return 'Congratulations! You are now a verified expert';
      case ExpertApplicationStatus.rejected:
        return 'Your application was not approved at this time';
      case ExpertApplicationStatus.underReview:
        return 'Our team is currently reviewing your application';
    }
  }
}
