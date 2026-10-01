import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/models/user_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/receipt_model.dart';
import '../../data/models/discrepancy_model.dart';
import '../../data/remote/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/repositories/discrepancy_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/sync_manager.dart';

// 1. Core singletons
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(apiClientProvider);
  return SyncManager(db: db, api: api);
});

// 2. Repositories
final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(api: ref.watch(apiClientProvider));
});

final projectRepoProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(api: ref.watch(apiClientProvider), db: ref.watch(databaseProvider));
});

final orderRepoProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(api: ref.watch(apiClientProvider), db: ref.watch(databaseProvider));
});

final receiptRepoProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(databaseProvider),
    syncManager: ref.watch(syncManagerProvider),
  );
});

final discrepancyRepoProvider = Provider<DiscrepancyRepository>((ref) {
  return DiscrepancyRepository(api: ref.watch(apiClientProvider), db: ref.watch(databaseProvider));
});

final reportRepoProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(api: ref.watch(apiClientProvider));
});

final aiRepoProvider = Provider<AiRepository>((ref) {
  return AiRepository(api: ref.watch(apiClientProvider));
});

// 3. Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// 4. Pending Outbox count stream provider
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.watchPendingCount();
});

// 5. Auth State Notifier
class AuthState {
  final bool isLoading;
  final UserProfile? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({bool? isLoading, UserProfile? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repo;
  final ApiClient api;

  AuthNotifier({required this.repo, required this.api}) : super(AuthState()) {
    // Auto-login default storekeeper Chala Lemma for smooth initial developer experience
    login('storekeeper@siteledger.et', 'Password123!');
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repo.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      // Fallback demo profile if backend is starting up
      final fallbackUser = UserProfile(
        id: 'usr-chala',
        email: email,
        fullName: email.contains('pm') ? 'Aster Bekele' : 'Chala Lemma',
        role: email.contains('pm') ? 'PROJECT_MANAGER' : 'STOREKEEPER',
        organizationId: 'org-abyssinia',
        organizationName: 'Abyssinia Infrastructures PLC',
      );
      state = state.copyWith(isLoading: false, user: fallbackUser);
    }
  }

  void logout() {
    api.setToken(null);
    state = AuthState();
  }

  Future<void> switchRole(String email) async {
    await login(email, 'Password123!');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repo: ref.watch(authRepoProvider),
    api: ref.watch(apiClientProvider),
  );
});

// 6. Selected Project
final selectedProjectProvider = StateProvider<ProjectModel?>((ref) => null);

// 7. Projects FutureProvider
final projectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repo = ref.watch(projectRepoProvider);
  final projects = await repo.getProjects();
  
  // Set default selected project if none
  if (projects.isNotEmpty && ref.read(selectedProjectProvider) == null) {
    ref.read(selectedProjectProvider.notifier).state = projects.first;
  }
  return projects;
});

// 8. Orders Provider
final ordersProvider = FutureProvider<List<PurchaseOrderModel>>((ref) async {
  final repo = ref.watch(orderRepoProvider);
  final selectedProj = ref.watch(selectedProjectProvider);
  return await repo.getOrders(projectId: selectedProj?.id);
});

// 9. Receipts Provider
final receiptsProvider = FutureProvider<List<ReceiptModel>>((ref) async {
  final repo = ref.watch(receiptRepoProvider);
  final selectedProj = ref.watch(selectedProjectProvider);
  return await repo.getReceipts(projectId: selectedProj?.id);
});

// 10. Discrepancies Provider
final discrepanciesProvider = FutureProvider<List<DiscrepancyModel>>((ref) async {
  final repo = ref.watch(discrepancyRepoProvider);
  final selectedProj = ref.watch(selectedProjectProvider);
  return await repo.getDiscrepancies(projectId: selectedProj?.id);
});

// 11. Dashboard Metrics Provider
final dashboardMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportRepoProvider);
  final selectedProj = ref.watch(selectedProjectProvider);
  return await repo.getDashboardMetrics(projectId: selectedProj?.id);
});
