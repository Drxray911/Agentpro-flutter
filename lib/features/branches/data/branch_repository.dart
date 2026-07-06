import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_exception.dart';
import '../domain/branch_models.dart';

/// Repository implementing spec §5.5 branch + user endpoints.
class BranchRepository {
  final Dio _dio;
  const BranchRepository(this._dio);

  /// GET /branches
  Future<List<Branch>> listBranches() async {
    try {
      final resp = await _dio.get('/branches');
      return (resp.data['data'] as List)
          .map((j) => Branch.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) return Branch.demoList();
      throw AppException.fromDio(e);
    }
  }

  /// POST /branches
  Future<Branch> createBranch({required String name, required String location, required String region}) async {
    try {
      final resp = await _dio.post('/branches', data: {'name': name, 'location': location, 'region': region});
      return Branch.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }

  /// GET /users?role=agent&branch_id=
  Future<List<StaffMember>> listStaff({String? branchId, String? role}) async {
    try {
      final resp = await _dio.get('/users', queryParameters: {
        if (branchId != null) 'branch_id': branchId,
        if (role != null) 'role': role,
      });
      return (resp.data['data'] as List)
          .map((j) => StaffMember.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (_isOffline(e)) return StaffMember.demoList();
      throw AppException.fromDio(e);
    }
  }

  /// POST /users/invite
  Future<void> inviteStaff({required String phone, required String role, required String branchId}) async {
    try {
      await _dio.post('/users/invite', data: {'phone': phone, 'role': role, 'branch_id': branchId});
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }

  /// PUT /users/:id/status
  Future<void> updateStaffStatus(String userId, String status) async {
    try {
      await _dio.put('/users/$userId/status', data: {'status': status});
    } catch (e) {
      throw AppException.fromDio(e);
    }
  }

  bool _isOffline(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;
}

final branchRepositoryProvider = Provider<BranchRepository>(
  (ref) => BranchRepository(ref.watch(dioProvider)),
);

/// AsyncNotifier holding the branch list for the current business.
class BranchListNotifier extends AsyncNotifier<List<Branch>> {
  @override
  Future<List<Branch>> build() => ref.read(branchRepositoryProvider).listBranches();

  Future<void> add(Branch branch) async {
    final current = state.value ?? [];
    state = AsyncData([...current, branch]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(branchRepositoryProvider).listBranches());
  }
}

final branchListProvider = AsyncNotifierProvider<BranchListNotifier, List<Branch>>(
  BranchListNotifier.new,
);

/// AsyncNotifier holding staff for the current business.
class StaffListNotifier extends AsyncNotifier<List<StaffMember>> {
  @override
  Future<List<StaffMember>> build() => ref.read(branchRepositoryProvider).listStaff();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(branchRepositoryProvider).listStaff());
  }
}

final staffListProvider = AsyncNotifierProvider<StaffListNotifier, List<StaffMember>>(
  StaffListNotifier.new,
);
