import 'package:flutter/material.dart';
import 'package:transaksi/data/models/paginated_user_response.dart';
import 'package:transaksi/data/models/user.dart';
import 'package:transaksi/data/services/api_service.dart';

// Asumsi Anda memiliki AuthProvider untuk mengelola state otentikasi
// import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State untuk data user
  List<User> _users = [];
  PaginatedUserResponse? _paginatedResponse;

  // State untuk kontrol UI
  bool _isLoading = false;
  String? _errorMessage;

  // Getters untuk mengakses state dari UI
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreUsers =>
      _paginatedResponse == null ||
      _paginatedResponse!.currentPage < _paginatedResponse!.lastPage;

  // Method utama untuk mengambil data user dari API
  Future<void> fetchUsers(
    String token, {
    bool isRefresh = false,
    String? search,
    String? role,
  }) async {
    // Jika sedang loading atau sudah tidak ada data lagi, jangan lakukan apa-apa
    if (_isLoading) return;
    if (!isRefresh && !hasMoreUsers) return;

    _isLoading = true;
    _errorMessage = null; // Hapus error lama saat request baru
    if (isRefresh) {
      _users = [];
      _paginatedResponse = null; // Reset paginasi saat refresh
    }
    notifyListeners();

    try {
      final int pageToFetch = isRefresh
          ? 1
          : (_paginatedResponse!.currentPage + 1);

      final response = await _apiService.getUsers(
        token,
        page: pageToFetch,
        search: search,
        role: role,
      );

      _users.addAll(response.users);
      _paginatedResponse = response; // Simpan seluruh data paginasi
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Membuat user baru dan me-refresh daftar jika berhasil.
  /// Mengembalikan true jika berhasil, false jika gagal.
  Future<bool> createUser(
    String token, {
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createUser(
        token,
        name: name,
        email: email,
        password: password,
        role: role,
      );
      // Jika berhasil, refresh seluruh daftar untuk menampilkan user baru
      await fetchUsers(token, isRefresh: true);
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }

  /// Mengupdate user dan memperbarui data di list lokal.
  /// Mengembalikan true jika berhasil, false jika gagal.
  Future<bool> updateUser(
    String token,
    int userId, {
    String? name,
    String? email,
    String? password,
    String? role,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUser(
        token,
        userId,
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Cari index user yang akan diupdate
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser; // Ganti dengan data yang baru
        notifyListeners();
      }
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false; // Gagal
    }
  }

  /// Menghapus user dan menghapusnya dari list lokal.
  /// Mengembalikan true jika berhasil, false jika gagal.
  Future<bool> deleteUser(String token, int userId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteUser(token, userId);
      _users.removeWhere((user) => user.id == userId); // Hapus dari list
      notifyListeners();
      return true; // Sukses
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false; // Gagal
    }
  }
}
