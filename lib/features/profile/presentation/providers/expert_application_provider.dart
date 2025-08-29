import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/expert_application_service.dart';
import '../../domain/models/expert_application.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

// Service provider
final expertApplicationServiceProvider = Provider<ExpertApplicationService>((ref) {
  return ExpertApplicationService();
});

// Submit application provider
final submitExpertApplicationProvider = FutureProvider.family<String, ExpertApplication>((ref, application) async {
  final service = ref.read(expertApplicationServiceProvider);
  return await service.submitApplication(application);
});

// User application provider - gets current user's application
final userExpertApplicationProvider = FutureProvider<ExpertApplication?>((ref) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return currentUserAsync.when(
    data: (user) async {
      if (user == null) return null;
      
      final service = ref.read(expertApplicationServiceProvider);
      return await service.getUserApplication(user.id);
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

// Check if user has applied provider
final hasUserAppliedProvider = FutureProvider<bool>((ref) async {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return currentUserAsync.when(
    data: (user) async {
      if (user == null) return false;
      
      final service = ref.read(expertApplicationServiceProvider);
      return await service.hasUserApplied(user.id);
    },
    loading: () => false,
    error: (error, stack) => false,
  );
});

// Watch user application status (real-time updates)
final watchUserApplicationProvider = StreamProvider<ExpertApplication?>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return currentUserAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      
      final service = ref.read(expertApplicationServiceProvider);
      return service.watchUserApplication(user.id);
    },
    loading: () => Stream.value(null),
    error: (error, stack) => Stream.value(null),
  );
});

// Application submission state notifier
class ExpertApplicationNotifier extends StateNotifier<AsyncValue<String?>> {
  ExpertApplicationNotifier(this._service) : super(const AsyncValue.data(null));

  final ExpertApplicationService _service;

  Future<void> submitApplication(ExpertApplication application) async {
    state = const AsyncValue.loading();
    
    try {
      final applicationId = await _service.submitApplication(application);
      state = AsyncValue.data(applicationId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final expertApplicationNotifierProvider = StateNotifierProvider<ExpertApplicationNotifier, AsyncValue<String?>>((ref) {
  final service = ref.read(expertApplicationServiceProvider);
  return ExpertApplicationNotifier(service);
});
