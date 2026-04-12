import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'Product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(products: fetchProducts()));
}

class MyApp extends StatelessWidget {
  final Future<List<Product>> products;
  const MyApp({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Product Navigation', products: products),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Future<List<Product>> products;
  const MyHomePage({super.key, required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text("Lỗi: ${snapshot.error}");
            
            if (snapshot.hasData) {
              // Khi có dữ liệu thì hiện danh sách
              return ProductBoxList(items: snapshot.data!);
            }
            
            // Mặc định hiện vòng xoay khi đang tải
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
List<Product> parseProducts(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Product>((json) => Product.fromJson(json)).toList();
}

Future<List<Product>> fetchProducts() async {
  // Đọc file JSON từ assets
  final String response = await rootBundle.loadString('assets/products.json');
  
  // Giả lập độ trễ 1 giây để giống fetch thật
  await Future.delayed(const Duration(seconds: 1));

  return parseProducts(response);
}

class ProductBoxList extends StatelessWidget {
  final List<Product> items;
  const ProductBoxList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ProductBox(item: items[index]);
      },
    );
  }
}

class ProductBox extends StatelessWidget {
  final Product item;
  const ProductBox({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[100],
              child: _buildImage(item.image),
            ),
          ),
          const SizedBox(width: 16.0),
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price}đ',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF5B5B),
                      ),
                    ),
                    const Icon(
                      Icons.add_circle,
                      color: Color(0xFFEF5B5B),
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageSource) {
    if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
      );
    } else {
      // Assuming local asset if not URL
      // Prefixes with assets/appimages/ if needed, or uses as is
      String assetPath = imageSource.contains('/') ? imageSource : 'assets/appimages/$imageSource';
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
      );
    }
  }
}