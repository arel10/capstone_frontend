import 'package:flutter/material.dart';
import 'package:transaksi/data/models/product_model.dart';
import 'package:transaksi/data/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String _searchQuery = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _currentPage <= _lastPage;

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  Future<void> fetchProducts(String token) async {
    if (_isLoadingMore || !hasMorePages || _isLoading) return;

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();
    _errorMessage = null;

    try {
      final paginatedResponse = await _apiService.getProducts(
        token: token,
        page: _currentPage,
        search: _searchQuery,
      );

      if (_currentPage == 1) {
        _products = paginatedResponse.products;
      } else {
        _products.addAll(paginatedResponse.products);
      }
      _lastPage = paginatedResponse.lastPage;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts(String token) async {
    _currentPage = 1;
    _lastPage = 1;
    _products = [];
    notifyListeners();
    await fetchProducts(token);
  }

  // --- FUNGSI CRUD (TIDAK ADA PERUBAHAN) ---
  Future<bool> createProduct(String token, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addProduct(token, data);
      if (response['success'] == true) {
        await refreshProducts(token);
        return true;
      }
      throw Exception(response['message'] ?? 'Failed to create product');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> editProduct(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.updateProduct(token, id, data);
      if (response['success'] == true) {
        await refreshProducts(token);
        return true;
      }
      throw Exception(response['message'] ?? 'Failed to update product');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProduct(String token, int id) async {
    try {
      final response = await _apiService.deleteProduct(token, id);
      if (response['success'] == true) {
        await refreshProducts(token);
        return true;
      }
      throw Exception(response['message'] ?? 'Failed to delete product');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
