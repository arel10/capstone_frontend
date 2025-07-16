import 'dart:ui'; // <-- TAMBAHKAN IMPORT INI untuk efek blur (ImageFilter)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transaksi/data/models/product_model.dart';
import 'package:transaksi/providers/cart_provider.dart';

// --- Anda bisa meletakkan konstanta ini di file tema atau di sini untuk kemudahan ---
const kPrimaryColor = Color(0xFF0D47A1); // Biru tua yang elegan
const kAccentColor = Color(0xFF42A5F5); // Biru yang lebih cerah untuk aksen
const kTextColor = Color(0xFF212121);
const kSubtitleColor = Color(0xFF757575);
const kBackgroundColor = Color(0xFFFFFFFF); // Latar belakang putih bersih
const kSheetColor = Color(0xFFF5F5F5); // Warna sedikit abu untuk sheet

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock <= 0;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(context, isOutOfStock),
            _buildInfoSection(context, isOutOfStock),
          ],
        ),
      ),
      // --- Tombol Aksi (CTA) yang selalu terlihat di bawah ---
      bottomNavigationBar: (isAdmin || isOutOfStock)
          ? _buildDisabledBottomBar(isOutOfStock)
          : _buildAddToCartButton(context),
    );
  }

  // Widget untuk AppBar dengan efek blur
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk bagian gambar produk
  Widget _buildImageSection(BuildContext context, bool isOutOfStock) {
    return Hero(
      tag: 'product-image-${product.id}',
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ? DecorationImage(
                  image: NetworkImage(product.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (product.imageUrl == null || product.imageUrl!.isEmpty)
              Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
              ),
            if (isOutOfStock)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    'STOK HABIS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget untuk bagian informasi produk dengan layout sheet
  Widget _buildInfoSection(BuildContext context, bool isOutOfStock) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(
        0,
        -30,
      ), // Membuat sheet tumpang tindih dengan gambar
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stok: ${product.stock}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(product.price),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(color: Colors.black12, thickness: 1),
            ),
            Text(
              'Deskripsi Produk',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.description ?? 'Tidak ada deskripsi untuk produk ini.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: kSubtitleColor,
                height: 1.6, // Jarak antar baris untuk keterbacaan
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol "Tambah ke Keranjang"
  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SizedBox(
        height: 55,
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.shopping_cart_checkout_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'TAMBAH KE KERANJANG',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} ditambahkan ke keranjang.'),
                backgroundColor: kAccentColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(15),
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Widget untuk bottom bar saat tombol dinonaktifkan (stok habis atau admin)
  Widget _buildDisabledBottomBar(bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors
          .transparent, // tidak perlu warna karena tombol akan ada di atas konten
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: null, // Tombol non-aktif
          child: Text(
            isAdmin ? 'MODE ADMIN' : 'STOK HABIS',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
