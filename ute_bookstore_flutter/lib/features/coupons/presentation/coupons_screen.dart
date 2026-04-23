import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/admin_theme.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/search_bar_widget.dart';
import '../data/coupon_models.dart';
import 'coupon_state.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

enum _CouponStatusFilter { all, active, expired, usedUp }

enum _CouponScopeFilter { all, publicOnly, privateOnly }

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  final _searchController = TextEditingController();
  _CouponStatusFilter _statusFilter = _CouponStatusFilter.all;
  _CouponScopeFilter _scopeFilter = _CouponScopeFilter.all;

  String _statusQuery(_CouponStatusFilter value) {
    switch (value) {
      case _CouponStatusFilter.active:
        return 'active';
      case _CouponStatusFilter.expired:
        return 'expired';
      case _CouponStatusFilter.usedUp:
        return 'used_up';
      case _CouponStatusFilter.all:
        return 'all';
    }
  }

  String _scopeQuery(_CouponScopeFilter value) {
    switch (value) {
      case _CouponScopeFilter.publicOnly:
        return 'public';
      case _CouponScopeFilter.privateOnly:
        return 'private';
      case _CouponScopeFilter.all:
        return 'all';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(couponNotifierProvider.notifier).loadCoupons();
      await ref.read(couponNotifierProvider.notifier).refreshStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(couponNotifierProvider.notifier).loadCoupons(
          search: _searchController.text.trim(),
          status: _statusQuery(_statusFilter),
          scope: _scopeQuery(_scopeFilter),
        );
    await ref.read(couponNotifierProvider.notifier).refreshStats();
  }

  Future<void> _showCouponForm({Coupon? coupon}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CouponForm(coupon: coupon),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _deleteCoupon(Coupon coupon) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa mã giảm giá'),
        content: Text('Xác nhận xóa mã ${coupon.code}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(couponNotifierProvider.notifier).delete(coupon.id);
    }
  }

  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value).replaceAll(',', '.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(couponNotifierProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Mã giảm giá'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mã'),
        backgroundColor: AdminColors.primary,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _StatsRow(stats: state.stats),
            const SizedBox(height: 12),
            SearchBarWidget(
              controller: _searchController,
              hintText: 'Tìm mã giảm giá',
              onChanged: (value) {
                ref.read(couponNotifierProvider.notifier).loadCoupons(
                      search: value.trim(),
                      status: _statusQuery(_statusFilter),
                      scope: _scopeQuery(_scopeFilter),
                    );
              },
            ),
            const SizedBox(height: 12),
            _FilterRow(
              status: _statusFilter,
              scope: _scopeFilter,
              onStatusChanged: (value) {
                setState(() => _statusFilter = value);
                ref.read(couponNotifierProvider.notifier).loadCoupons(
                      search: _searchController.text.trim(),
                      status: _statusQuery(value),
                      scope: _scopeQuery(_scopeFilter),
                    );
              },
              onScopeChanged: (value) {
                setState(() => _scopeFilter = value);
                ref.read(couponNotifierProvider.notifier).loadCoupons(
                      search: _searchController.text.trim(),
                      status: _statusQuery(_statusFilter),
                      scope: _scopeQuery(value),
                    );
              },
            ),
            const SizedBox(height: 12),
            if (state.isLoading)
              const _LoadingList()
            else if (state.items.isEmpty)
              const _EmptyState()
            else
              ...state.items.map(
                (coupon) => _CouponCard(
                  coupon: coupon,
                  formatCurrency: _formatCurrency,
                  onEdit: () => _showCouponForm(coupon: coupon),
                  onDelete: () => _deleteCoupon(coupon),
                ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, end: 0),
              ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _ErrorBanner(message: state.errorMessage!),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final CouponStats? stats;

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 800 ? 4 : width >= 520 ? 2 : 1;
        final items = [
          _StatCard(
            title: 'Đang hoạt động',
            value: stats!.activeCount.toString(),
            icon: Icons.verified_rounded,
            color: AdminColors.success,
          ),
          _StatCard(
            title: 'Sắp hết hạn',
            value: stats!.expiringSoonCount.toString(),
            icon: Icons.schedule_rounded,
            color: AdminColors.warning,
          ),
          _StatCard(
            title: 'Tổng lượt dùng',
            value: stats!.totalUsedCount.toString(),
            icon: Icons.stacked_bar_chart_rounded,
            color: AdminColors.secondary,
          ),
          _StatCard(
            title: 'Dùng nhiều nhất',
            value: stats!.topUsedCode?.isNotEmpty == true ? stats!.topUsedCode! : '—',
            icon: Icons.local_fire_department_rounded,
            color: AdminColors.primary,
            subtitle: '${stats!.topUsedCount} lượt',
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 3.6 : 2.2,
          ),
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.status,
    required this.scope,
    required this.onStatusChanged,
    required this.onScopeChanged,
  });

  final _CouponStatusFilter status;
  final _CouponScopeFilter scope;
  final ValueChanged<_CouponStatusFilter> onStatusChanged;
  final ValueChanged<_CouponScopeFilter> onScopeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            _buildChip('Tất cả', _CouponStatusFilter.all),
            _buildChip('Hoạt động', _CouponStatusFilter.active),
            _buildChip('Hết hạn', _CouponStatusFilter.expired),
            _buildChip('Hết lượt', _CouponStatusFilter.usedUp),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Phạm vi', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            _buildScopeChip('Tất cả', _CouponScopeFilter.all),
            _buildScopeChip('Toàn hệ thống', _CouponScopeFilter.publicOnly),
            _buildScopeChip('Cá nhân', _CouponScopeFilter.privateOnly),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, _CouponStatusFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: status == value,
      onSelected: (_) => onStatusChanged(value),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildScopeChip(String label, _CouponScopeFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: scope == value,
      onSelected: (_) => onScopeChanged(value),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.formatCurrency,
    required this.onEdit,
    required this.onDelete,
  });

  final Coupon coupon;
  final String Function(num value) formatCurrency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = coupon.resolvedStatus;
    final statusColor = _statusColor(status);
    final expiryText = coupon.expiryDate == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(coupon.expiryDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              _StatusChip(label: _statusLabel(status), color: statusColor),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Loại giảm',
                  value: coupon.isPercent
                      ? 'Giảm ${coupon.discountPercent}%'
                      : 'Giảm ${formatCurrency(coupon.discountAmount ?? 0)}',
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'Đơn tối thiểu',
                  value: formatCurrency(coupon.minOrderValue ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Giảm tối đa',
                  value: formatCurrency(coupon.maxDiscount ?? 0),
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'HSD',
                  value: expiryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Đã dùng',
                  value: '${coupon.usedCount} / ${coupon.usageLimit ?? '∞'}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AdminColors.success;
      case 'USED_UP':
        return AdminColors.warning;
      case 'EXPIRED':
        return AdminColors.danger;
      default:
        return AdminColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Hoạt động';
      case 'USED_UP':
        return 'Hết lượt';
      case 'EXPIRED':
        return 'Hết hạn';
      default:
        return '—';
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Row(
        children: const [
          Icon(Icons.local_offer_outlined, color: AdminColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Text('Chưa có mã giảm giá nào.', style: TextStyle(color: AdminColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _cardDecoration.copyWith(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AdminColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AdminColors.danger))),
        ],
      ),
    );
  }
}

class _CouponForm extends ConsumerStatefulWidget {
  const _CouponForm({this.coupon});

  final Coupon? coupon;

  @override
  ConsumerState<_CouponForm> createState() => _CouponFormState();
}

class _CouponFormState extends ConsumerState<_CouponForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _percentController;
  late final TextEditingController _amountController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _usageController;
  late final TextEditingController _customerController;
  DateTime? _expiryDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    _codeController = TextEditingController(text: coupon?.code ?? '');
    _percentController = TextEditingController(text: coupon?.discountPercent?.toString() ?? '');
    _amountController = TextEditingController(text: coupon?.discountAmount?.toString() ?? '');
    _minController = TextEditingController(text: coupon?.minOrderValue?.toString() ?? '');
    _maxController = TextEditingController(text: coupon?.maxDiscount?.toString() ?? '');
    _usageController = TextEditingController(text: coupon?.usageLimit?.toString() ?? '');
    _customerController = TextEditingController(text: coupon?.customerId ?? '');
    _expiryDate = coupon?.expiryDate;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _percentController.dispose();
    _amountController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _usageController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final initial = _expiryDate ?? now.add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  int? _parseInt(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  bool _validateDiscountTypes() {
    final percent = _parseInt(_percentController) ?? 0;
    final amount = _parseInt(_amountController) ?? 0;
    return (percent > 0) ^ (amount > 0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_validateDiscountTypes()) {
      _showSnack('Chỉ chọn 1 loại giảm giá (% hoặc tiền).');
      return;
    }
    if (_expiryDate == null || _expiryDate!.isBefore(DateTime.now())) {
      _showSnack('Ngày hết hạn phải lớn hơn hôm nay.');
      return;
    }

    setState(() => _isSaving = true);

    final request = CouponRequest(
      code: _codeController.text.trim(),
      discountPercent: _parseInt(_percentController),
      discountAmount: _parseInt(_amountController),
      minOrderValue: _parseInt(_minController),
      maxDiscount: _parseInt(_maxController),
      expiryDate: _expiryDate!,
      usageLimit: _parseInt(_usageController),
      customerId: _customerController.text.trim(),
    );

    try {
      if (widget.coupon == null) {
        await ref.read(couponNotifierProvider.notifier).create(request);
      } else {
        await ref.read(couponNotifierProvider.notifier).update(widget.coupon!.id, request);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiryText = _expiryDate == null
        ? 'Chọn ngày'
        : DateFormat('dd/MM/yyyy').format(_expiryDate!);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.coupon == null ? 'Thêm mã giảm giá' : 'Chỉnh sửa mã giảm giá',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Mã code'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _percentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giảm %'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giảm tiền'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Đơn tối thiểu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giảm tối đa'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số lượt dùng'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickExpiryDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AdminColors.primary),
                      const SizedBox(width: 8),
                      Text('Hạn sử dụng: $expiryText'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AdminButton(
                label: widget.coupon == null ? 'Tạo mã giảm giá' : 'Cập nhật',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _cardDecoration = BoxDecoration(
  color: AdminColors.surface,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
  ],
);

