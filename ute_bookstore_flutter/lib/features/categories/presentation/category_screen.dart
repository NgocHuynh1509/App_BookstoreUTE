import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../theme/admin_theme.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  late final Dio _dio;

  final TextEditingController _searchController = TextEditingController();

  List<CategoryItem> _categories = [];
  List<CategoryItem> _filteredCategories = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _searchController.addListener(_filterCategories);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Options> _authOptions() async {
    final sessionStorage = ref.read(sessionStorageProvider);

    final token = await sessionStorage.getToken(); // hoặc read('token')
    if (token == null || token.isEmpty) {
      throw Exception('Không tìm thấy token đăng nhập');
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final response = await _dio.get(
        '/api/admin/categories',
        options: await _authOptions(),
      );

      final data = response.data as List;
      final items = data
          .map((e) => CategoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      setState(() {
        _categories = items;
        _filteredCategories = items;
      });
    } catch (e) {
      _showSnackBar('Không tải được danh mục: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _filterCategories() {
    final keyword = _searchController.text.trim().toLowerCase();
    setState(() {
      if (keyword.isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories.where((c) {
          return c.categoryId.toLowerCase().contains(keyword) ||
              c.categoryName.toLowerCase().contains(keyword);
        }).toList();
      }
    });
  }

  Future<void> _openCreateDialog() async {
    final nameController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm danh mục'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên danh mục',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  _showSnackBar('Tên danh mục không được để trống', isError: true);
                  return;
                }
                Navigator.pop(context, true);
                await _createCategory(name);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      nameController.dispose();
    }
  }

  Future<void> _createCategory(String name) async {
    setState(() => _submitting = true);
    try {
      await _dio.post(
        '/api/admin/categories',
        data: {'categoryName': name},
        options: await _authOptions(),
      );
      _showSnackBar('Thêm danh mục thành công');
      await _loadCategories();
    } catch (e) {
      _showSnackBar('Thêm danh mục thất bại: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _openEditDialog(CategoryItem item) async {
    final nameController = TextEditingController(text: item.categoryName);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa danh mục'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên danh mục',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  _showSnackBar('Tên danh mục không được để trống', isError: true);
                  return;
                }
                Navigator.pop(context, true);
                await _updateCategory(item.categoryId, name);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (updated == true) {
      nameController.dispose();
    }
  }

  Future<void> _updateCategory(String id, String name) async {
    setState(() => _submitting = true);
    try {
      await _dio.put(
        '/api/admin/categories/$id',
        data: {'categoryName': name},
        options: await _authOptions(),
      );
      _showSnackBar('Cập nhật danh mục thành công');
      await _loadCategories();
    } catch (e) {
      _showSnackBar('Cập nhật thất bại: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteCategory(CategoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn có chắc muốn xóa danh mục "${item.categoryName}" không?'),
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

    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      await _dio.delete(
        '/api/admin/categories/${item.categoryId}',
        options: await _authOptions(),
      );
      _showSnackBar('Xóa danh mục thành công');
      await _loadCategories();
    } catch (e) {
      _showSnackBar('Xóa thất bại: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Danh mục'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // SEARCH
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm danh mục...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AdminColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AdminColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AdminColors.border),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // BUTTON THÊM
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _openCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                ? const Center(child: Text('Chưa có danh mục nào'))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _filteredCategories[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AdminColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.category_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.categoryName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Mã: ${item.categoryId}'),
                            Text('Số sách: ${item.bookCount}'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _submitting ? null : () => _openEditDialog(item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: item.bookCount > 0
                            ? 'Không thể xóa danh mục đang có sách'
                            : 'Xóa',
                        onPressed: (_submitting || item.bookCount > 0)
                            ? null
                            : () => _deleteCategory(item),
                        icon: Icon(
                          Icons.delete_outline,
                          color: item.bookCount > 0 ? Colors.grey : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String categoryId;
  final String categoryName;
  final int bookCount;

  CategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.bookCount,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
    );
  }
}