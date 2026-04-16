import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/session_storage.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/dashboard/data/dashboard_api.dart';
import '../features/orders/data/order_api.dart';
import '../features/products/data/product_api.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError('SessionStorage override required');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient override required');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(AuthApi(apiClient), ref.read(sessionStorageProvider));
});

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ref.read(apiClientProvider));
});

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.read(apiClientProvider));
});

final orderApiProvider = Provider<OrderApi>((ref) {
  return OrderApi(ref.read(apiClientProvider));
});
