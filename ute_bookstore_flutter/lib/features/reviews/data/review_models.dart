class Review {
  final String fullName;
  final int rating;
  final String comment;
  final String creationDate;

  Review({
    required this.fullName,
    required this.rating,
    required this.comment,
    required this.creationDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      fullName: json['full_name']?.toString() ?? 'Ẩn danh',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      creationDate: json['creation_date']?.toString() ?? '',
    );
  }
}

class ReviewSummary {
  final double averageRating;
  final int reviewCount;

  ReviewSummary({
    required this.averageRating,
    required this.reviewCount,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

