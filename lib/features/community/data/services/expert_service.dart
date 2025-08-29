import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../profile/domain/models/expert_application.dart';
import '../../domain/models/expert.dart';

class ExpertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _expertApplicationsCollection = 'expert_applications';

  /// Get all approved experts
  Future<List<Expert>> getApprovedExperts({int limit = 50}) async {
    try {
      // Query approved experts without orderBy to avoid index requirement
      // We'll sort in memory for now
      final querySnapshot = await _firestore
          .collection(_expertApplicationsCollection)
          .where('status', isEqualTo: ExpertApplicationStatus.approved.name)
          .limit(limit)
          .get();

      final experts = <Expert>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convert ExpertApplication to Expert
          final application = ExpertApplication.fromJson(data);
          
          final expert = Expert.fromApplication(
            applicationId: doc.id,
            userId: application.userId,
            userName: application.userName,
            userEmail: application.userEmail,
            specialty: application.specialty,
            bio: application.bio,
            credentials: application.credentials,
            approvedAt: application.reviewedAt,
          );
          
          experts.add(expert);
        } catch (e) {
          print('Error converting expert application ${doc.id}: $e');
          // Skip this document and continue with others
          continue;
        }
      }

      // Sort experts by approval date in memory (most recent first)
      experts.sort((a, b) {
        if (a.approvedAt == null && b.approvedAt == null) return 0;
        if (a.approvedAt == null) return 1;
        if (b.approvedAt == null) return -1;
        return b.approvedAt!.compareTo(a.approvedAt!);
      });

      print('Fetched and sorted ${experts.length} approved experts');
      return experts;
    } catch (e) {
      print('Error fetching approved experts: $e');
      throw Exception('Failed to fetch experts: $e');
    }
  }

  /// Stream of approved experts for real-time updates
  Stream<List<Expert>> watchApprovedExperts({int limit = 50}) {
    return _firestore
        .collection(_expertApplicationsCollection)
        .where('status', isEqualTo: ExpertApplicationStatus.approved.name)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final experts = <Expert>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convert ExpertApplication to Expert
          final application = ExpertApplication.fromJson(data);
          
          final expert = Expert.fromApplication(
            applicationId: doc.id,
            userId: application.userId,
            userName: application.userName,
            userEmail: application.userEmail,
            specialty: application.specialty,
            bio: application.bio,
            credentials: application.credentials,
            approvedAt: application.reviewedAt,
          );
          
          experts.add(expert);
        } catch (e) {
          print('Error converting expert application ${doc.id}: $e');
          // Skip this document and continue with others
          continue;
        }
      }

      // Sort experts by approval date in memory (most recent first)
      experts.sort((a, b) {
        if (a.approvedAt == null && b.approvedAt == null) return 0;
        if (a.approvedAt == null) return 1;
        if (b.approvedAt == null) return -1;
        return b.approvedAt!.compareTo(a.approvedAt!);
      });

      return experts;
    });
  }

  /// Get expert by user ID
  Future<Expert?> getExpertByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_expertApplicationsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: ExpertApplicationStatus.approved.name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      
      // Convert ExpertApplication to Expert
      final application = ExpertApplication.fromJson(data);
      
      return Expert.fromApplication(
        applicationId: doc.id,
        userId: application.userId,
        userName: application.userName,
        userEmail: application.userEmail,
        specialty: application.specialty,
        bio: application.bio,
        credentials: application.credentials,
        approvedAt: application.reviewedAt,
      );
    } catch (e) {
      print('Error fetching expert by user ID: $e');
      throw Exception('Failed to fetch expert: $e');
    }
  }

  /// Get expert statistics
  Future<Map<String, int>> getExpertStatistics() async {
    try {
      final totalQuery = await _firestore
          .collection(_expertApplicationsCollection)
          .where('status', isEqualTo: ExpertApplicationStatus.approved.name)
          .get();

      // For recent experts, we'll filter in memory to avoid compound query
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      int recentCount = 0;
      
      for (final doc in totalQuery.docs) {
        try {
          final data = doc.data();
          if (data['reviewedAt'] != null) {
            final reviewedAt = DateTime.tryParse(data['reviewedAt'].toString());
            if (reviewedAt != null && reviewedAt.isAfter(thirtyDaysAgo)) {
              recentCount++;
            }
          }
        } catch (e) {
          // Skip invalid documents
          continue;
        }
      }

      return {
        'totalExperts': totalQuery.docs.length,
        'recentExperts': recentCount,
      };
    } catch (e) {
      print('Error fetching expert statistics: $e');
      return {
        'totalExperts': 0,
        'recentExperts': 0,
      };
    }
  }
}
