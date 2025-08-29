import 'package:flutter_test/flutter_test.dart';
import 'package:plantwise/features/profile/domain/models/expert_application.dart';

void main() {
  group('ExpertApplication', () {
    test('should create ExpertApplication correctly', () {
      // Arrange
      const application = ExpertApplication(
        userId: 'test_user_id',
        userEmail: 'test@example.com',
        userName: 'Test User',
        specialty: 'Indoor Plant Care',
        experience: '5-10 years',
        bio: 'I love taking care of plants.',
        credentials: ['Certified Horticulturist'],
        status: ExpertApplicationStatus.pending,
      );

      // Assert
      expect(application.userId, equals('test_user_id'));
      expect(application.userEmail, equals('test@example.com'));
      expect(application.userName, equals('Test User'));
      expect(application.specialty, equals('Indoor Plant Care'));
      expect(application.experience, equals('5-10 years'));
      expect(application.bio, equals('I love taking care of plants.'));
      expect(application.credentials, contains('Certified Horticulturist'));
      expect(application.status, equals(ExpertApplicationStatus.pending));
    });

    test('should convert to and from JSON correctly', () {
      // Arrange
      const application = ExpertApplication(
        id: 'app_123',
        userId: 'user_456',
        userEmail: 'john@example.com',
        userName: 'John Doe',
        specialty: 'Outdoor Gardening',
        experience: '10+ years',
        bio: 'Passionate gardener with extensive experience.',
        credentials: ['Master Gardener', 'Plant Disease Specialist'],
        status: ExpertApplicationStatus.approved,
      );

      // Act
      final json = application.toJson();
      final fromJson = ExpertApplication.fromJson(json);

      // Assert
      expect(fromJson.id, equals(application.id));
      expect(fromJson.userId, equals(application.userId));
      expect(fromJson.userEmail, equals(application.userEmail));
      expect(fromJson.userName, equals(application.userName));
      expect(fromJson.specialty, equals(application.specialty));
      expect(fromJson.experience, equals(application.experience));
      expect(fromJson.bio, equals(application.bio));
      expect(fromJson.credentials, equals(application.credentials));
      expect(fromJson.status, equals(application.status));
    });

    test('should return correct display names for status', () {
      expect(ExpertApplicationStatus.pending.displayName, equals('Pending Review'));
      expect(ExpertApplicationStatus.approved.displayName, equals('Approved'));
      expect(ExpertApplicationStatus.rejected.displayName, equals('Rejected'));
      expect(ExpertApplicationStatus.underReview.displayName, equals('Under Review'));
    });

    test('should return correct descriptions for status', () {
      expect(ExpertApplicationStatus.pending.description, contains('waiting to be reviewed'));
      expect(ExpertApplicationStatus.approved.description, contains('Congratulations'));
      expect(ExpertApplicationStatus.rejected.description, contains('not approved'));
      expect(ExpertApplicationStatus.underReview.description, contains('currently reviewing'));
    });
  });
}
