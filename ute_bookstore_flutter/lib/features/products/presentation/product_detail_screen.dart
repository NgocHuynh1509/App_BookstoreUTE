import 'package:flutter/material.dart';

import '../../../widgets/primary_button.dart';
import '../data/product_models.dart';
import 'preview_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiet sach'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              product.picture,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text('Tac gia: ${product.author}'),
          Text('Nha xuat ban: ${product.publisher}'),
          if (product.publicationYear != null)
            Text('Nam xuat ban: ${product.publicationYear}'),
          const SizedBox(height: 12),
          Text(
            'Gia: ${product.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description.isEmpty ? 'Chua co mo ta.' : product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Them vao gio',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PreviewScreen()),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Doc thu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
