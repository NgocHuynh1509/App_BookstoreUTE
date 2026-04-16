import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/product_models.dart';
import '../data/product_repository.dart';

class ProductState {
  final List<Product> items;
  final bool isLoading;
  final int page;
  final int totalPages;
  final String search;
  final String categoryId;

  ProductState({
    required this.items,
    required this.isLoading,
    required this.page,
    required this.totalPages,
    required this.search,
    required this.categoryId,
  });

  factory ProductState.initial() {
    return ProductState(
      items: const [],
      isLoading: false,
      page: 0,
      totalPages: 1,
      search: '',
      categoryId: '',
    );
  }

  ProductState copyWith({
    List<Product>? items,
    bool? isLoading,
    int? page,
    int? totalPages,
    String? search,
    String? categoryId,
  }) {
    return ProductState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(this._repository) : super(ProductState.initial());

  final ProductRepository _repository;

  Future<void> loadFirstPage({String? search, String? categoryId}) async {
    state = state.copyWith(isLoading: true, page: 0);
    final page = await _repository.fetchProducts(
      page: 0,
      size: 20,
      search: search ?? state.search,
      categoryId: categoryId ?? state.categoryId,
    );

    state = state.copyWith(
      isLoading: false,
      items: page.items,
      page: 0,
      totalPages: page.totalPages,
      search: search ?? state.search,
      categoryId: categoryId ?? state.categoryId,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.page + 1 >= state.totalPages) return;
    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    final page = await _repository.fetchProducts(
      page: nextPage,
      size: 20,
      search: state.search,
      categoryId: state.categoryId,
    );

    state = state.copyWith(
      isLoading: false,
      items: [...state.items, ...page.items],
      page: nextPage,
      totalPages: page.totalPages,
    );
  }

  Future<void> delete(String bookId) async {
    await _repository.delete(bookId);
    state = state.copyWith(
      items: state.items.where((e) => e.bookId != bookId).toList(),
    );
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final api = ref.read(productApiProvider);
  return ProductRepository(api);
});

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productRepositoryProvider));
});

