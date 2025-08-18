import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/group.dart';

class GroupsService {
  static const String _groupsCollection = 'groups';
  static const String _userGroupsCollection = 'user_groups';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Create a new group
  Future<Group> createGroup({
    required String name,
    required String description,
    required GroupCategory category,
    String? imageUrl,
    bool isPublic = true,
    List<String> tags = const [],
  }) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to create a group');
    }

    final user = _auth.currentUser!;
    final groupId = _firestore.collection(_groupsCollection).doc().id;

    final group = Group(
      id: groupId,
      name: name,
      description: description,
      adminId: user.uid,
      adminName: user.displayName ?? 'Anonymous',
      memberIds: [user.uid], // Admin is automatically a member
      createdAt: DateTime.now(),
      category: category,
      imageUrl: imageUrl,
      isPublic: isPublic,
      tags: tags,
    );

    // Create group document
    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .set(group.toJson());

    // Add to user's groups
    await _addUserToGroup(user.uid, groupId);

    return group;
  }

  /// Join a group by ID
  Future<void> joinGroup(String groupId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to join a group');
    }

    final groupDoc = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final group = Group.fromJson(groupDoc.data()!);

    // Check if user is already a member
    if (group.isMember(currentUserId!)) {
      throw Exception('User is already a member of this group');
    }

    // Add user to group's member list
    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayUnion([currentUserId!]),
    });

    // Add to user's groups
    await _addUserToGroup(currentUserId!, groupId);
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to leave a group');
    }

    final groupDoc = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final group = Group.fromJson(groupDoc.data()!);

    // Check if user is admin - admins can't leave their own groups
    if (group.isAdmin(currentUserId!)) {
      throw Exception('Group admin cannot leave the group. Transfer ownership first.');
    }

    // Remove user from group's member list
    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayRemove([currentUserId!]),
    });

    // Remove from user's groups
    await _removeUserFromGroup(currentUserId!, groupId);
  }

  /// Get groups the current user has joined
  Stream<List<Group>> getUserGroups() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_groupsCollection)
        .where('memberIds', arrayContains: currentUserId!)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Search for public groups
  Stream<List<Group>> searchPublicGroups({
    String? searchQuery,
    GroupCategory? category,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_groupsCollection)
        .where('isPublic', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      var groups = snapshot.docs
          .map((doc) => Group.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Client-side filtering for search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        groups = groups.where((group) =>
            group.name.toLowerCase().contains(lowerQuery) ||
            group.description.toLowerCase().contains(lowerQuery) ||
            group.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))).toList();
      }

      return groups;
    });
  }

  /// Get a specific group by ID
  Future<Group?> getGroup(String groupId) async {
    final doc = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .get();

    if (!doc.exists) return null;

    return Group.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Update group information (admin only)
  Future<void> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? imageUrl,
    bool? isPublic,
    List<String>? tags,
  }) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to update a group');
    }

    final group = await getGroup(groupId);
    if (group == null) {
      throw Exception('Group not found');
    }

    if (!group.isAdmin(currentUserId!)) {
      throw Exception('Only group admin can update group information');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (imageUrl != null) updates['imageUrl'] = imageUrl;
    if (isPublic != null) updates['isPublic'] = isPublic;
    if (tags != null) updates['tags'] = tags;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .update(updates);
    }
  }

  /// Delete a group (admin only)
  Future<void> deleteGroup(String groupId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to delete a group');
    }

    final group = await getGroup(groupId);
    if (group == null) {
      throw Exception('Group not found');
    }

    if (!group.isAdmin(currentUserId!)) {
      throw Exception('Only group admin can delete the group');
    }

    // Remove group from all users' group lists
    for (final memberId in group.memberIds) {
      await _removeUserFromGroup(memberId, groupId);
    }

    // Delete the group document
    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .delete();
  }

  /// Add user to group in user_groups collection
  Future<void> _addUserToGroup(String userId, String groupId) async {
    await _firestore
        .collection(_userGroupsCollection)
        .doc(userId)
        .set({
      'groupIds': FieldValue.arrayUnion([groupId]),
    }, SetOptions(merge: true));
  }

  /// Remove user from group in user_groups collection
  Future<void> _removeUserFromGroup(String userId, String groupId) async {
    await _firestore
        .collection(_userGroupsCollection)
        .doc(userId)
        .update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
  }
}
