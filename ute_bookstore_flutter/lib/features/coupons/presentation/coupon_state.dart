import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/coupon_models.dart';
import '../data/coupon_repository.dart';

class CouponState {
  CouponState({
    required this.items,
    required this.isLoading,
    required this.search,
    required this.statusFilter,
    required this.scopeFilter,
    required this.errorMessage,
    required this.stats,
  });

  final List<Coupon> items;
  final bool isLoading;
  final String search;
  final String statusFilter;
  final String scopeFilter;
  final String? errorMessage;
  final CouponStats? stats;

  factory CouponState.initial() {
    return CouponState(
      items: const [],
      isLoading: false,
      search: '',
      statusFilter: 'all',
      scopeFilter: 'all',
      errorMessage: null,
      stats: null,
    );
  }

  CouponState copyWith({
    List<Coupon>? items,
    bool? isLoading,
    String? search,
    String? statusFilter,
    String? scopeFilter,
    String? errorMessage,
    CouponStats? stats,
  }) {
    return CouponState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      scopeFilter: scopeFilter ?? this.scopeFilter,
      errorMessage: errorMessage,
      stats: stats ?? this.stats,
    );
  }
}

class CouponNotifier extends StateNotifier<CouponState> {
  CouponNotifier(this._repository) : super(CouponState.initial());

  final CouponRepository _repository;

  Future<void> loadCoupons({
    String? search,
    String? status,
    String? scope,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchCoupons(
        search: search ?? state.search,
        status: status ?? state.statusFilter,
        scope: scope ?? state.scopeFilter,
      );
      state = state.copyWith(
        isLoading: false,
        items: items,
        search: search ?? state.search,
        statusFilter: status ?? state.statusFilter,
        scopeFilter: scope ?? state.scopeFilter,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshStats() async {
    try {
      final stats = await _repository.fetchStats();
      state = state.copyWith(stats: stats, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> create(CouponRequest request) async {
    await _repository.create(request);
    await loadCoupons();
    await refreshStats();
  }

  Future<void> update(String id, CouponRequest request) async {
    await _repository.update(id, request);
    await loadCoupons();
    await refreshStats();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
    await refreshStats();
  }
}

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final api = ref.read(couponApiProvider);
  return CouponRepository(api);
});

final couponNotifierProvider = StateNotifierProvider<CouponNotifier, CouponState>((ref) {
  return CouponNotifier(ref.read(couponRepositoryProvider));
});

