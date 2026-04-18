class DashboardSummary {
  final int totalBooks;
  final int totalOrders;
  final double revenueDay;
  final double revenueMonth;
  final double revenueYear;
  final int pendingOrders;
  final int lowStockBooks;
  final int unreadMessages;

  DashboardSummary({
    required this.totalBooks,
    required this.totalOrders,
    required this.revenueDay,
    required this.revenueMonth,
    required this.revenueYear,
    required this.pendingOrders,
    required this.lowStockBooks,
    required this.unreadMessages,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBooks: (json['totalBooks'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      revenueDay: (json['revenueDay'] as num?)?.toDouble() ?? 0,
      revenueMonth: (json['revenueMonth'] as num?)?.toDouble() ?? 0,
      revenueYear: (json['revenueYear'] as num?)?.toDouble() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      lowStockBooks: (json['lowStockBooks'] as num?)?.toInt() ?? 0,
      unreadMessages: (json['unreadMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

