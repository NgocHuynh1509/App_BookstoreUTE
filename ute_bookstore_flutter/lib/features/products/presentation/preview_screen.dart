import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdfx/pdfx.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  static const String previewUrl =
      'https://drive.google.com/uc?export=download&id=1AHBpFrvx1b4hRQfSzx_XRQHVYFWhHtCk';

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  PdfControllerPinch? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(PreviewScreen.previewUrl);
      _controller = PdfControllerPinch(
        document: PdfDocument.openFile(file.path),
      );
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc thử'),
      ),
      body: _errorMessage != null
          ? _PreviewError(message: _errorMessage!, onRetry: _loadPdf)
          : _controller == null
              ? const Center(child: CircularProgressIndicator())
              : PdfViewPinch(
                  controller: _controller!,
                  scrollDirection: Axis.vertical,
                  backgroundDecoration: const BoxDecoration(color: Colors.white),
                ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Không thể tải file PDF',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
