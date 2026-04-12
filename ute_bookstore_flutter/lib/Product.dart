class Product {
  final String name;
  final String description;
  final int price;
  final String image;

  Product(this.name, this.description, this.price, this.image);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['name'] ?? '',
      json['description'] ?? '',
      json['price'] ?? 0,
      json['image'] ?? '',
    );
  }
}