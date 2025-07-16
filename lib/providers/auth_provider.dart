import 'package:flutter/material.dart';
import 'package:transaksi/data/models/User.dart';
import 'package:transaksi/data/services/api_service.dart';
import 'package:transaksi/data/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  AuthProvider() {
    _tryAutoLogin();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      if (response['success'] == true) {
        _token = response['data']['token'];
        _user = User.fromMap(response['data']['user']);

        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!);

        notifyListeners();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
    _setLoading(false);
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (response['success'] == true) {
        // Otomatis login setelah register berhasil
        _token = response['data']['token'];
        _user = User.fromMap(response['data']['user']);

        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!);

        notifyListeners();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_token != null) {
        await _apiService.logout(_token!);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      _token = null;
      _user = null;
      await _storageService.clearAll();
      notifyListeners();
      _setLoading(false);
    }
  }

  Future<void> _tryAutoLogin() async {
    final token = await _storageService.getToken();
    if (token == null) {
      return;
    }

    final user = await _storageService.getUser();
    if (user == null) {
      return;
    }

    _token = token;
    _user = user;
    notifyListeners();
  }
}
