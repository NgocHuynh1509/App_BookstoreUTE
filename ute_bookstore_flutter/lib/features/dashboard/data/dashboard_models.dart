class DashboardSummary {
  final int totalBooks;
  final int totalOrders;
  final int totalUsers;
  final double revenueDay;
  final double revenueMonth;
  final double revenueYear;
  final int pendingOrders;
  final int lowStockBooks;
  final int unreadMessages;

  DashboardSummary({
    required this.totalBooks,
    required this.totalOrders,
    required this.totalUsers,
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
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      revenueDay: (json['revenueDay'] as num?)?.toDouble() ?? 0,
      revenueMonth: (json['revenueMonth'] as num?)?.toDouble() ?? 0,
      revenueYear: (json['revenueYear'] as num?)?.toDouble() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      lowStockBooks: (json['lowStockBooks'] as num?)?.toInt() ?? 0,
      unreadMessages: (json['unreadMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardSeriesPoint {
  final String label;
  final double value;

  DashboardSeriesPoint({
    required this.label,
    required this.value,
  });

  factory DashboardSeriesPoint.fromJson(Map<String, dynamic> json) {
    return DashboardSeriesPoint(
      label: json['label']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DashboardStatusCount {
  final String label;
  final int count;

  DashboardStatusCount({
    required this.label,
    required this.count,
  });

  factory DashboardStatusCount.fromJson(Map<String, dynamic> json) {
    return DashboardStatusCount(
      label: json['label']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardRevenueResponse {
  final String range;
  final double total;
  final double previousTotal;
  final double changePercent;
  final List<DashboardSeriesPoint> series;

  DashboardRevenueResponse({
    required this.range,
    required this.total,
    required this.previousTotal,
    required this.changePercent,
    required this.series,
  });

  factory DashboardRevenueResponse.fromJson(Map<String, dynamic> json) {
    final rawSeries = (json['series'] as List<dynamic>? ?? []);
    return DashboardRevenueResponse(
      range: json['range']?.toString() ?? 'month',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      previousTotal: (json['previousTotal'] as num?)?.toDouble() ?? 0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
      series: rawSeries
          .map((item) => DashboardSeriesPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardBooksResponse {
  final String range;
  final int totalBooks;
  final int soldBooks;
  final int stockBooks;
  final int lowStockBooks;

  DashboardBooksResponse({
    required this.range,
    required this.totalBooks,
    required this.soldBooks,
    required this.stockBooks,
    required this.lowStockBooks,
  });

  factory DashboardBooksResponse.fromJson(Map<String, dynamic> json) {
    return DashboardBooksResponse(
      range: json['range']?.toString() ?? 'month',
      totalBooks: (json['totalBooks'] as num?)?.toInt() ?? 0,
      soldBooks: (json['soldBooks'] as num?)?.toInt() ?? 0,
      stockBooks: (json['stockBooks'] as num?)?.toInt() ?? 0,
      lowStockBooks: (json['lowStockBooks'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardOrdersResponse {
  final String range;
  final int totalOrders;
  final double completionRate;
  final List<DashboardStatusCount> statusCounts;

  DashboardOrdersResponse({
    required this.range,
    required this.totalOrders,
    required this.completionRate,
    required this.statusCounts,
  });

  factory DashboardOrdersResponse.fromJson(Map<String, dynamic> json) {
    final rawCounts = (json['statusCounts'] as List<dynamic>? ?? []);
    return DashboardOrdersResponse(
      range: json['range']?.toString() ?? 'month',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      statusCounts: rawCounts
          .map((item) => DashboardStatusCount.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardChartsResponse {
  final String range;
  final List<DashboardStatusCount> orderStatus;
  final List<DashboardStatusCount> categoryBreakdown;
  final List<DashboardSeriesPoint> revenueSeries;
  final List<DashboardSeriesPoint> ordersSeries;
  final List<DashboardSeriesPoint> booksSoldSeries;

  DashboardChartsResponse({
    required this.range,
    required this.orderStatus,
    required this.categoryBreakdown,
    required this.revenueSeries,
    required this.ordersSeries,
    required this.booksSoldSeries,
  });

  factory DashboardChartsResponse.fromJson(Map<String, dynamic> json) {
    List<DashboardStatusCount> parseCounts(String key) {
      final raw = (json[key] as List<dynamic>? ?? []);
      return raw
          .map((item) => DashboardStatusCount.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<DashboardSeriesPoint> parseSeries(String key) {
      final raw = (json[key] as List<dynamic>? ?? []);
      return raw
          .map((item) => DashboardSeriesPoint.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return DashboardChartsResponse(
      range: json['range']?.toString() ?? 'month',
      orderStatus: parseCounts('orderStatus'),
      categoryBreakdown: parseCounts('categoryBreakdown'),
      revenueSeries: parseSeries('revenueSeries'),
      ordersSeries: parseSeries('ordersSeries'),
      booksSoldSeries: parseSeries('booksSoldSeries'),
    );
  }
}

class DashboardRevenuePredictionResponse {
  final double predictedAmount;
  final double currentMonthTotal;
  final double changePercent;
  final double confidence;
  final double mae;
  final double mse;
  final double rmse;
  final double r2;
  final String suggestion;
  final String predictedLabel;
  final int forecastIndex;
  final List<DashboardSeriesPoint> series;

  DashboardRevenuePredictionResponse({
    required this.predictedAmount,
    required this.currentMonthTotal,
    required this.changePercent,
    required this.confidence,
    required this.mae,
    required this.mse,
    required this.rmse,
    required this.r2,
    required this.suggestion,
    required this.predictedLabel,
    required this.forecastIndex,
    required this.series,
  });

  factory DashboardRevenuePredictionResponse.fromJson(Map<String, dynamic> json) {
    final rawSeries = (json['series'] as List<dynamic>? ?? []);
    return DashboardRevenuePredictionResponse(
      predictedAmount: (json['predictedAmount'] as num?)?.toDouble() ?? 0,
      currentMonthTotal: (json['currentMonthTotal'] as num?)?.toDouble() ?? 0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      mae: (json['mae'] as num?)?.toDouble() ?? 0,
      mse: (json['mse'] as num?)?.toDouble() ?? 0,
      rmse: (json['rmse'] as num?)?.toDouble() ?? 0,
      r2: (json['r2'] as num?)?.toDouble() ?? 0,
      suggestion: json['suggestion']?.toString() ?? '',
      predictedLabel: json['predictedLabel']?.toString() ?? '',
      forecastIndex: (json['forecastIndex'] as num?)?.toInt() ?? 0,
      series: rawSeries
          .map((item) => DashboardSeriesPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardTopBooksResponse {
  final List<DashboardTopBook> items;

  DashboardTopBooksResponse({required this.items});

  factory DashboardTopBooksResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    return DashboardTopBooksResponse(
      items: rawItems
          .map((item) => DashboardTopBook.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardTopBook {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;
  final int soldQuantity;
  final double revenue;

  DashboardTopBook({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.soldQuantity,
    required this.revenue,
  });

  factory DashboardTopBook.fromJson(Map<String, dynamic> json) {
    return DashboardTopBook(
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      soldQuantity: (json['soldQuantity'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DashboardRecentActivitiesResponse {
  final List<DashboardRecentActivity> items;

  DashboardRecentActivitiesResponse({required this.items});

  factory DashboardRecentActivitiesResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    return DashboardRecentActivitiesResponse(
      items: rawItems
          .map((item) => DashboardRecentActivity.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardRecentActivity {
  final String type;
  final String title;
  final String subtitle;
  final String time;

  DashboardRecentActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  factory DashboardRecentActivity.fromJson(Map<String, dynamic> json) {
    return DashboardRecentActivity(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}
