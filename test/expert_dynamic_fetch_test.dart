import 'package:flutter_test/flutter_test.dart';
import 'package:plantwise/features/community/domain/models/expert.dart';
import 'package:plantwise/features/profile/domain/models/expert_application.dart';

void main() {
  group('Expert Model Tests', () {
    test('Expert.fromApplication should create Expert with dummy data', () {
      // Given: An expert application data
      const applicationId = 'test-app-id';
      const userId = 'test-user-123';
      const userName = 'Dr. Sarah Green';
      const userEmail = 'sarah@example.com';
      const specialty = 'Indoor Plant Specialist';
      const bio = 'I have been caring for indoor plants for 15+ years';
      const credentials = ['PhD in Botany', 'Certified Horticulturist'];
      final approvedAt = DateTime.now();

      // When: Creating Expert from application data
      final expert = Expert.fromApplication(
        applicationId: applicationId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        specialty: specialty,
        bio: bio,
        credentials: credentials,
        approvedAt: approvedAt,
      );

      // Then: Expert should have correct data including dummy rating and followers
      expect(expert.id, equals(applicationId));
      expect(expert.userId, equals(userId));
      expect(expert.name, equals(userName));
      expect(expert.email, equals(userEmail));
      expect(expert.specialty, equals(specialty));
      expect(expert.bio, equals(bio));
      expect(expert.credentials, equals(credentials));
      expect(expert.approvedAt, equals(approvedAt));
      
      // Dummy data should be generated consistently
      expect(expert.rating, greaterThanOrEqualTo(4.0));
      expect(expert.rating, lessThanOrEqualTo(5.0));
      expect(expert.followers, greaterThanOrEqualTo(50));
      expect(expert.followers, lessThan(10000));
    });

    test('Expert model should generate consistent dummy data for same userId', () {
      // Given: Same user ID
      const userId = 'consistent-user-id';
      
      // When: Creating two experts with same userId
      final expert1 = Expert.fromApplication(
        applicationId: 'app1',
        userId: userId,
        userName: 'Test Expert',
        userEmail: 'test@example.com',
        specialty: 'Plant Care',
        bio: 'Expert in plant care',
        credentials: [],
      );
      
      final expert2 = Expert.fromApplication(
        applicationId: 'app2',
        userId: userId,
        userName: 'Test Expert',
        userEmail: 'test@example.com',
        specialty: 'Plant Care',
        bio: 'Expert in plant care',
        credentials: [],
      );

      // Then: Both should have same rating and followers
      expect(expert1.rating, equals(expert2.rating));
      expect(expert1.followers, equals(expert2.followers));
    });

    test('Expert model should generate different dummy data for different userIds', () {
      // Given: Different user IDs
      const userId1 = 'user-1';
      const userId2 = 'user-2';
      
      // When: Creating experts with different userIds
      final expert1 = Expert.fromApplication(
        applicationId: 'app1',
        userId: userId1,
        userName: 'Expert One',
        userEmail: 'one@example.com',
        specialty: 'Plant Care',
        bio: 'Expert in plant care',
        credentials: [],
      );
      
      final expert2 = Expert.fromApplication(
        applicationId: 'app2',
        userId: userId2,
        userName: 'Expert Two',
        userEmail: 'two@example.com',
        specialty: 'Plant Care',
        bio: 'Expert in plant care',
        credentials: [],
      );

      // Then: They should likely have different rating and followers
      // (Note: There's a small chance they could be equal, but statistically unlikely)
      expect(expert1.rating != expert2.rating || expert1.followers != expert2.followers, isTrue);
    });

    test('Expert defaults should be correct', () {
      // When: Creating an expert with minimal data
      final expert = Expert(
        id: 'test-id',
        userId: 'test-user',
        name: 'Test Expert',
        email: 'test@example.com',
        specialty: 'Testing',
        bio: 'Test bio',
      );

      // Then: Defaults should be applied
      expect(expert.credentials, isEmpty);
      expect(expert.rating, equals(4.0));
      expect(expert.followers, equals(0));
      expect(expert.avatar, isNull);
      expect(expert.approvedAt, isNull);
    });
  });
}
