import 'package:flutter/material.dart';
import 'package:transaksi/data/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;
  int get totalItemsInCart {
    int count = 0;
    _items.forEach((key, cartItem) => count += cartItem.quantity);
    return count;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach(
      (key, cartItem) => total += cartItem.product.price * cartItem.quantity,
    );
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(product.id, () => CartItem(product: product));
    }
    notifyListeners();
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
