import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/search_bar_widget.dart';
import '../../../theme/admin_theme.dart';
import '../data/product_models.dart';
import 'product_detail_screen.dart';
import 'product_state.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

enum _ProductSort { newest, priceAsc, priceDesc, bestSeller }

enum _ProductStatusFilter { all, active, outOfStock, hidden }

class _ProductFilterResult {
  const _ProductFilterResult({
    required this.categoryId,
    required this.status,
    required this.sort,
  });

  final String categoryId;
  final _ProductStatusFilter status;
  final _ProductSort sort;
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  _ProductSort _sort = _ProductSort.newest;
  _ProductStatusFilter _statusFilter = _ProductStatusFilter.all;
  final _categoryController = TextEditingController();
  bool _isSyncing = false;

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
    _categoryController.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value).replaceAll(',', '.')}đ';
  }

  List<Product> _applyFilters(List<Product> items) {
    Iterable<Product> filtered = items;
    switch (_statusFilter) {
      case _ProductStatusFilter.active:
        filtered = filtered.where((p) => p.isActive && p.quantity > 0);
        break;
      case _ProductStatusFilter.outOfStock:
        filtered = filtered.where((p) => p.quantity <= 0);
        break;
      case _ProductStatusFilter.hidden:
        filtered = filtered.where((p) => !p.isActive);
        break;
      case _ProductStatusFilter.all:
        break;
    }

    final list = filtered.toList();
    switch (_sort) {
      case _ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _ProductSort.bestSeller:
        list.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
        break;
      case _ProductSort.newest:
        break;
    }
    return list;
  }

  Future<void> _showFilterSheet() async {
    final controller = TextEditingController(text: _categoryController.text);
    var tempStatus = _statusFilter;
    var tempSort = _sort;
    final result = await showModalBottomSheet<_ProductFilterResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc nâng cao',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Mã danh mục (CategoryId)',
                  hintText: 'VD: C01',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Trạng thái hiển thị'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusChip('Tất cả', _ProductStatusFilter.all, tempStatus,
                      (value) => setModalState(() => tempStatus = value)),
                  _buildStatusChip('Còn hàng', _ProductStatusFilter.active, tempStatus,
                      (value) => setModalState(() => tempStatus = value)),
                  _buildStatusChip('Hết hàng', _ProductStatusFilter.outOfStock, tempStatus,
                      (value) => setModalState(() => tempStatus = value)),
                  _buildStatusChip('Đang ẩn', _ProductStatusFilter.hidden, tempStatus,
                      (value) => setModalState(() => tempStatus = value)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Sắp xếp'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip('Mới nhất', _ProductSort.newest, tempSort,
                      (value) => setModalState(() => tempSort = value)),
                  _buildSortChip('Giá ↑', _ProductSort.priceAsc, tempSort,
                      (value) => setModalState(() => tempSort = value)),
                  _buildSortChip('Giá ↓', _ProductSort.priceDesc, tempSort,
                      (value) => setModalState(() => tempSort = value)),
                  _buildSortChip('Bán chạy', _ProductSort.bestSeller, tempSort,
                      (value) => setModalState(() => tempSort = value)),
                ],
              ),
              const SizedBox(height: 16),
              AdminButton(
                label: 'Áp dụng',
                onPressed: () => Navigator.pop(
                  context,
                  _ProductFilterResult(
                    categoryId: controller.text.trim(),
                    status: tempStatus,
                    sort: tempSort,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      final shouldReload = result.categoryId != _categoryController.text.trim();
      setState(() {
        _statusFilter = result.status;
        _sort = result.sort;
        _categoryController.text = result.categoryId;
      });
      if (shouldReload) {
        await ref.read(productNotifierProvider.notifier).loadFirstPage(
              search: _searchController.text.trim(),
              categoryId: result.categoryId,
            );
      }
    }
  }

  Widget _buildStatusChip(
    String label,
    _ProductStatusFilter value,
    _ProductStatusFilter selected,
    ValueChanged<_ProductStatusFilter> onSelected,
  ) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSortChip(
    String label,
    _ProductSort value,
    _ProductSort selected,
    ValueChanged<_ProductSort> onSelected,
  ) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
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
      ref.read(productNotifierProvider.notifier).loadFirstPage(
            search: _searchController.text.trim(),
            categoryId: _categoryController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);
    final filteredItems = _applyFilters(state.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        actions: [
          IconButton(
            onPressed: _isSyncing
                ? null
                : () async {
              setState(() => _isSyncing = true);
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang đồng bộ dữ liệu...')),
                );

                await ref.read(productRepositoryProvider).syncSearchAndMl();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đồng bộ thành công')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() => _isSyncing = false);
                }
              }
            },
            icon: _isSyncing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.sync),
            tooltip: 'Đồng bộ ML',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AdminColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý sản phẩm',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    final searchBar = Expanded(
                      child: SearchBarWidget(
                        controller: _searchController,
                        hintText: 'Tìm theo tên, tác giả, ISBN...',
                        onChanged: (_) {},
                      ),
                    );
                    final searchAction = IconButton(
                      onPressed: () {
                        ref
                            .read(productNotifierProvider.notifier)
                            .loadFirstPage(search: _searchController.text.trim());
                      },
                      icon: const Icon(Icons.send_rounded, color: AdminColors.primary),
                    );
                    final addButton = AdminButton(
                      label: 'Thêm sản phẩm',
                      icon: Icons.add_rounded,
                      expand: !isNarrow,
                      onPressed: () => _showProductForm(),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [searchBar, const SizedBox(width: 8), searchAction]),
                          const SizedBox(height: 12),
                          addButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        searchBar,
                        const SizedBox(width: 8),
                        searchAction,
                        const SizedBox(width: 12),
                        SizedBox(width: 170, child: addButton),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showFilterSheet,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Bộ lọc'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng nhập CSV đang hoàn thiện.')),
                          );
                        },
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Nhập CSV'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng xuất báo cáo đang hoàn thiện.')),
                          );
                        },
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Xuất báo cáo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hiển thị ${filteredItems.length} / ${state.items.length} sản phẩm',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
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
                child: filteredItems.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Không có sản phẩm phù hợp')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filteredItems.length + (state.isLoading ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= filteredItems.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final item = filteredItems[index];
                          return _ProductCard(
                            product: item,
                            formatCurrency: _formatCurrency,
                            onEdit: () => _showProductForm(product: item),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xóa sản phẩm'),
                                  content: Text('Bạn chắc chắn muốn xóa "${item.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(productNotifierProvider.notifier)
                                    .delete(item.bookId);
                              }
                            },
                          )
                              .animate()
                              .fadeIn(duration: 260.ms, delay: (index * 25).ms)
                              .slideY(begin: 0.06, end: 0, duration: 260.ms, curve: Curves.easeOutCubic);
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
    required this.formatCurrency,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(num value) formatCurrency;

  String _statusLabel() {
    if (!product.isActive) return 'Đang ẩn';
    if (product.quantity <= 0) return 'Hết hàng';
    return 'Còn hàng';
  }

  Color _statusColor() {
    if (!product.isActive) return Colors.grey;
    if (product.quantity <= 0) return Colors.redAccent;
    return Colors.green;
  }

  List<String> _tags() {
    final tags = <String>[];
    if (product.soldQuantity >= 100) tags.add('Bán chạy');
    if (product.originalPrice != null && product.originalPrice! > product.price) {
      tags.add('Giảm giá');
    }
    if ((product.publicationYear ?? 0) >= DateTime.now().year - 1) {
      tags.add('Mới');
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final tags = _tags();
    final ratingText = product.reviewCount > 0
        ? '${product.averageRating.toStringAsFixed(1)} (${product.reviewCount})'
        : 'Chưa có đánh giá';

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
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.picture,
                width: 70,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 96,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Mã/ISBN: ${product.bookId}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text('Tác giả: ${product.author}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text('NXB: ${product.publisher}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text('Thể loại: ${product.categoryName}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        formatCurrency(product.price),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          formatCurrency(product.originalPrice!),
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        ratingText,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _InfoChip(label: 'Tồn: ${product.quantity}'),
                      _InfoChip(label: 'Đã bán: ${product.soldQuantity}'),
                      if (tags.isNotEmpty)
                        ...tags.map((tag) => _TagChip(label: tag)).toList(),
                    ],
                  ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF4C6FFF)),
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
  late final TextEditingController _publisherController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _descriptionController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _bookIdController = TextEditingController(text: p?.bookId ?? '');
    _titleController = TextEditingController(text: p?.title ?? '');
    _authorController = TextEditingController(text: p?.author ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _quantityController = TextEditingController(text: p?.quantity.toString() ?? '');
    _pictureController = TextEditingController(text: p?.picture ?? '');
    _categoryController = TextEditingController(text: p?.categoryId ?? '');
    _publisherController = TextEditingController(text: p?.publisher ?? '');
    _originalPriceController = TextEditingController(text: p?.originalPrice?.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _isActive = p?.isActive ?? true;
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
    _publisherController.dispose();
    _originalPriceController.dispose();
    _descriptionController.dispose();
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
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.product == null ? 'Thêm sách mới' : 'Cập nhật sách',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bookIdController,
              decoration: const InputDecoration(labelText: 'Mã sách / ISBN'),
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên sách'),
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Tác giả'),
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _publisherController,
              decoration: const InputDecoration(labelText: 'Nhà xuất bản'),
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Danh mục (CategoryId)'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá bán'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(labelText: 'Giá gốc (khuyến mãi)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Tồn kho'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Không được trống' : null,
            ),
            TextFormField(
              controller: _pictureController,
              decoration: const InputDecoration(labelText: 'Ảnh bìa (URL)'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              title: const Text('Hiển thị sản phẩm'),
              subtitle: const Text('Tắt để ẩn sản phẩm khỏi cửa hàng'),
            ),
            const SizedBox(height: 12),
            AdminButton(
              label: 'Lưu',
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final request = ProductRequest(
                  bookId: _bookIdController.text.trim(),
                  title: _titleController.text.trim(),
                  author: _authorController.text.trim(),
                  publisher: _publisherController.text.trim(),
                  publicationYear: widget.product?.publicationYear,
                  description: _descriptionController.text.trim(),
                  price: double.tryParse(_priceController.text.trim()) ?? 0,
                  originalPrice: double.tryParse(_originalPriceController.text.trim()),
                  quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
                  picture: _pictureController.text.trim(),
                  isActive: _isActive,
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

