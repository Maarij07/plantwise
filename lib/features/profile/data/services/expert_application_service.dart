import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/expert_application.dart';

class ExpertApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'expert_applications';

  /// Submit a new expert application
  Future<String> submitApplication(ExpertApplication application) async {
    try {
      // Create application data with timestamp
      final applicationData = application.copyWith(
        submittedAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .add(applicationData.toJson());

      print('Expert application submitted with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error submitting expert application: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Get user's expert application if exists
  Future<ExpertApplication?> getUserApplication(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id; // Add document ID

      return ExpertApplication.fromJson(data);
    } catch (e) {
      print('Error getting user expert application: $e');
      throw Exception('Failed to get application: $e');
    }
  }

  /// Check if user has already submitted an application
  Future<bool> hasUserApplied(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has applied: $e');
      return false;
    }
  }

  /// Update application status (admin function)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ExpertApplicationStatus status,
    String? reviewNotes,
    String? reviewedBy,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(applicationId).update({
        'status': status.name,
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewNotes': reviewNotes,
        'reviewedBy': reviewedBy,
      });

      print('Application status updated to: ${status.displayName}');
    } catch (e) {
      print('Error updating application status: $e');
      throw Exception('Failed to update application status: $e');
    }
  }

  /// Get all applications (admin function)
  Future<List<ExpertApplication>> getAllApplications({
    ExpertApplicationStatus? filterStatus,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('submittedAt', descending: true);

      if (filterStatus != null) {
        query = query.where('status', isEqualTo: filterStatus.name);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ExpertApplication.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all applications: $e');
      throw Exception('Failed to get applications: $e');
    }
  }

  /// Listen to user's application status changes
  Stream<ExpertApplication?> watchUserApplication(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return ExpertApplication.fromJson(data);
    });
  }

  /// Delete user's application (if they want to withdraw)
  Future<void> withdrawApplication(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        print('Application withdrawn successfully');
      }
    } catch (e) {
      print('Error withdrawing application: $e');
      throw Exception('Failed to withdraw application: $e');
    }
  }
}
