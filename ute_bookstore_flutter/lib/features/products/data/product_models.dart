class Product {
  final String bookId;
  final String title;
  final String author;
  final String publisher;
  final int? publicationYear;
  final String description;
  final double price;
  final double? originalPrice;
  final int quantity;
  final int soldQuantity;
  final bool isActive;
  final String picture;
  final String categoryId;
  final String categoryName;

  Product({
    required this.bookId,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.soldQuantity,
    required this.isActive,
    required this.picture,
    required this.categoryId,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      publicationYear: (json['publicationYear'] as num?)?.toInt(),
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      soldQuantity: (json['soldQuantity'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      picture: json['picture']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
    );
  }
}

class ProductRequest {
  final String bookId;
  final String title;
  final String author;
  final String publisher;
  final int? publicationYear;
  final String description;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String picture;
  final bool isActive;
  final String categoryId;

  ProductRequest({
    required this.bookId,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.picture,
    required this.isActive,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publicationYear': publicationYear,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'picture': picture,
      'isActive': isActive,
      'categoryId': categoryId,
    };
  }
}

