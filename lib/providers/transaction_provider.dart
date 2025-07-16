// lib/providers/transaction_provider.dart

// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:transaksi/data/models/transaction_model.dart';
import 'package:transaksi/data/services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Transaction> _transactions = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // State Sorting and Search
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  String _searchQuery = '';

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage <= _lastPage;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;

  Future<void> fetchTransactions(String token) async {
    if (_isLoadingMore || (!hasMore && _currentPage != 1)) return;

    if (_currentPage == 1) {
      _setLoading(true);
    } else {
      _setLoadingMore(true);
    }

    try {
      final response = await _apiService.getTransactions(
        token,
        page: _currentPage,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      if (response['success'] == true && response['data'] != null) {
        final paginated = PaginatedTransactionsResponse.fromJson(response);
        if (_currentPage == 1) {
          _transactions = paginated.transactions;
        } else {
          _transactions.addAll(paginated.transactions);
        }
        _lastPage = paginated.lastPage;

        if (_currentPage < _lastPage) {
          _currentPage++;
        } else {
          _currentPage = _lastPage + 1;
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load transactions');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  /// Refresh data
  Future<void> refresh(String token) async {
    _currentPage = 1;
    _lastPage = 1;
    _searchQuery = '';
    _transactions = [];
    notifyListeners();
    await fetchTransactions(token);
  }

  /// Sorting and Searching
  Future<void> changeSortAndRefresh(
    String token, {
    String? newSortBy,
    String? newSortOrder,
    String? newSearchQuery,
  }) async {
    _sortBy = newSortBy ?? _sortBy;
    _sortOrder = newSortOrder ?? _sortOrder;
    if (newSearchQuery != null) {
      _searchQuery = newSearchQuery;
    }

    // Refresh halaman
    _currentPage = 1;
    _lastPage = 1;
    _transactions = [];
    notifyListeners();
    await fetchTransactions(token);
  }

  Future<Map<String, dynamic>> createTransaction(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _apiService.createTransaction(token, items);
    if (response['success'] == true) {
      return response;
    } else {
      throw Exception(response['message'] ?? 'Failed to create transaction');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }
}
