import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/groups_service.dart';
import '../../domain/models/group.dart';

// Service provider
final groupsServiceProvider = Provider<GroupsService>((ref) {
  return GroupsService();
});

// User's joined groups provider
final userGroupsProvider = StreamProvider<List<Group>>((ref) {
  final service = ref.watch(groupsServiceProvider);
  return service.getUserGroups();
});

// Search provider for public groups
final searchGroupsProvider = StateNotifierProvider<SearchGroupsNotifier, SearchGroupsState>((ref) {
  final service = ref.watch(groupsServiceProvider);
  return SearchGroupsNotifier(service);
});

// State for group search
class SearchGroupsState {
  final List<Group> groups;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final GroupCategory? selectedCategory;

  const SearchGroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
  });

  SearchGroupsState copyWith({
    List<Group>? groups,
    bool? isLoading,
    String? error,
    String? searchQuery,
    GroupCategory? selectedCategory,
  }) {
    return SearchGroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Search groups notifier
class SearchGroupsNotifier extends StateNotifier<SearchGroupsState> {
  final GroupsService _service;

  SearchGroupsNotifier(this._service) : super(const SearchGroupsState());

  Future<void> searchGroups({
    String? query,
    GroupCategory? category,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query ?? state.searchQuery,
      selectedCategory: category,
    );

    try {
      // Listen to the stream and update state
      _service.searchPublicGroups(
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        category: state.selectedCategory,
      ).listen(
        (groups) {
          state = state.copyWith(
            groups: groups,
            isLoading: false,
          );
        },
        onError: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = const SearchGroupsState();
  }
}

// Group actions provider for creating, joining, leaving groups
final groupActionsProvider = StateNotifierProvider<GroupActionsNotifier, GroupActionsState>((ref) {
  final service = ref.watch(groupsServiceProvider);
  return GroupActionsNotifier(service);
});

// State for group actions
class GroupActionsState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const GroupActionsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  GroupActionsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return GroupActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

// Group actions notifier
class GroupActionsNotifier extends StateNotifier<GroupActionsState> {
  final GroupsService _service;

  GroupActionsNotifier(this._service) : super(const GroupActionsState());

  Future<Group?> createGroup({
    required String name,
    required String description,
    required GroupCategory category,
    String? imageUrl,
    bool isPublic = true,
    List<String> tags = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final group = await _service.createGroup(
        name: name,
        description: description,
        category: category,
        imageUrl: imageUrl,
        isPublic: isPublic,
        tags: tags,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Group "${group.name}" created successfully!',
      );

      return group;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> joinGroup(String groupId) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _service.joinGroup(groupId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Successfully joined the group!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      await _service.leaveGroup(groupId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Successfully left the group!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Provider for individual group details
final groupProvider = FutureProvider.family<Group?, String>((ref, groupId) async {
  final service = ref.watch(groupsServiceProvider);
  return service.getGroup(groupId);
});
