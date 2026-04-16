import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/primary_button.dart';
import '../data/product_models.dart';
import 'product_detail_screen.dart';
import 'product_state.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productNotifierProvider.notifier).loadFirstPage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showProductForm({Product? product}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ProductForm(product: product),
    );

    if (result == true) {
      ref.read(productNotifierProvider.notifier).loadFirstPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showProductForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên sách',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    ref
                        .read(productNotifierProvider.notifier)
                        .loadFirstPage(search: _searchController.text.trim());
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 120) {
                  ref.read(productNotifierProvider.notifier).loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(productNotifierProvider.notifier).loadFirstPage();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.items.length + (state.isLoading ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final item = state.items[index];
                    return _ProductCard(
                      product: item,
                      onEdit: () => _showProductForm(product: item),
                      onDelete: () => ref
                          .read(productNotifierProvider.notifier)
                          .delete(item.bookId),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.picture,
                width: 64,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('Tồn kho: ${product.quantity}'),
                  Text('Giá: ${product.price.toStringAsFixed(0)}'),
                  Text('Thể loại: ${product.categoryName}'),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({this.product});

  final Product? product;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bookIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _pictureController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _bookIdController = TextEditingController(text: p?.bookId ?? '');
    _titleController = TextEditingController(text: p?.title ?? '');
    _authorController = TextEditingController(text: p?.author ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _quantityController =
        TextEditingController(text: p?.quantity.toString() ?? '');
    _pictureController = TextEditingController(text: p?.picture ?? '');
    _categoryController = TextEditingController(text: p?.categoryId ?? '');
  }

  @override
  void dispose() {
    _bookIdController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _pictureController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(productRepositoryProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.product == null ? 'Thêm sản phẩm' : 'Cập nhật sản phẩm',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bookIdController,
              decoration: const InputDecoration(labelText: 'Mã sách'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên sách'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Tác giả'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Tồn kho'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _pictureController,
              decoration: const InputDecoration(labelText: 'Ảnh (URL)'),
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'CategoryId'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Lưu',
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final request = ProductRequest(
                  bookId: _bookIdController.text.trim(),
                  title: _titleController.text.trim(),
                  author: _authorController.text.trim(),
                  publisher: widget.product?.publisher ?? 'N/A',
                  publicationYear: widget.product?.publicationYear,
                  description: widget.product?.description ?? '',
                  price: double.tryParse(_priceController.text.trim()) ?? 0,
                  originalPrice: widget.product?.originalPrice,
                  quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
                  picture: _pictureController.text.trim(),
                  isActive: true,
                  categoryId: _categoryController.text.trim(),
                );

                if (widget.product == null) {
                  await repository.create(request);
                } else {
                  await repository.update(widget.product!.bookId, request);
                }

                if (!mounted) return;
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

