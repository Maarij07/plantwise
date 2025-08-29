import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/expert_service.dart';
import '../../domain/models/expert.dart';

// Expert service provider
final expertServiceProvider = Provider<ExpertService>((ref) {
  return ExpertService();
});

// Stream provider for approved experts (real-time updates)
final approvedExpertsStreamProvider = StreamProvider<List<Expert>>((ref) {
  final service = ref.read(expertServiceProvider);
  return service.watchApprovedExperts();
});

// Future provider for approved experts (one-time fetch)
final approvedExpertsProvider = FutureProvider<List<Expert>>((ref) async {
  final service = ref.read(expertServiceProvider);
  return service.getApprovedExperts();
});

// Provider for expert statistics
final expertStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(expertServiceProvider);
  return service.getExpertStatistics();
});

// Provider to get expert by user ID
final expertByUserIdProvider = FutureProvider.family<Expert?, String>((ref, userId) async {
  final service = ref.read(expertServiceProvider);
  return service.getExpertByUserId(userId);
});

// Expert list notifier for managing expert list state
class ExpertListNotifier extends StateNotifier<AsyncValue<List<Expert>>> {
  ExpertListNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadExperts();
  }

  final ExpertService _service;

  Future<void> _loadExperts() async {
    try {
      final experts = await _service.getApprovedExperts();
      state = AsyncValue.data(experts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh expert list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadExperts();
  }

  /// Search experts by specialty or name
  void searchExperts(String query) {
    state.whenData((experts) {
      if (query.isEmpty) {
        _loadExperts();
        return;
      }

      final filteredExperts = experts.where((expert) {
        return expert.name.toLowerCase().contains(query.toLowerCase()) ||
               expert.specialty.toLowerCase().contains(query.toLowerCase()) ||
               expert.bio.toLowerCase().contains(query.toLowerCase());
      }).toList();

      state = AsyncValue.data(filteredExperts);
    });
  }

  /// Filter experts by specialty
  void filterBySpecialty(String specialty) {
    state.whenData((experts) {
      if (specialty.isEmpty || specialty == 'All') {
        _loadExperts();
        return;
      }

      final filteredExperts = experts.where((expert) {
        return expert.specialty.toLowerCase().contains(specialty.toLowerCase());
      }).toList();

      state = AsyncValue.data(filteredExperts);
    });
  }
}

// Expert list notifier provider
final expertListNotifierProvider = StateNotifierProvider<ExpertListNotifier, AsyncValue<List<Expert>>>((ref) {
  final service = ref.read(expertServiceProvider);
  return ExpertListNotifier(service);
});

// Provider for unique specialties (for filtering)
final expertSpecialtiesProvider = FutureProvider<List<String>>((ref) async {
  final expertsAsync = ref.watch(approvedExpertsProvider);
  
  return expertsAsync.when(
    data: (experts) {
      final specialties = <String>{};
      for (final expert in experts) {
        specialties.add(expert.specialty);
      }
      final sortedSpecialties = specialties.toList()..sort();
      return ['All', ...sortedSpecialties];
    },
    loading: () => <String>[],
    error: (error, stack) => <String>[],
  );
});
