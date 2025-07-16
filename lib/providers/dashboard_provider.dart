import 'package:flutter/material.dart';
import 'package:transaksi/data/models/dashboard_model.dart';
import 'package:transaksi/data/services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchDashboardData(String token, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getDashboardData(token);
      if (response['success'] == true) {
        _dashboardData = DashboardData.fromJson(response['data'], role);
      } else {
        throw Exception(response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI BARU: Untuk membersihkan data saat logout ---
  void clearDashboardData() {
    _dashboardData = null;
    notifyListeners();
  }
}
