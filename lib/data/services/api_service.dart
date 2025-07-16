import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:transaksi/data/models/paginated_user_response.dart';
import 'package:transaksi/data/models/product_model.dart';
import 'package:transaksi/data/models/user.dart';
import 'package:transaksi/utils/app_constants.dart';

class ApiService {
  final String _baseUrl = AppConstants.baseUrl;

  //=====================//
  // ---  Authentikasi  --- //
  //=====================//

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return json.decode(response.body);
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );
    return json.decode(response.body);
  }

  // Fungsi untuk Logout
  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  //=====================//
  // ---  Dashboard  --- //
  //=====================//

  Future<Map<String, dynamic>> getDashboardData(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  //=====================//
  // ---  Product  --- //
  //=====================//

  Future<PaginatedProductsResponse> getProducts({
    required String token,
    int page = 1,
    String search = '',
  }) async {
    final Map<String, String> queryParameters = {'page': page.toString()};

    if (search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    final uri = Uri.parse(
      '$_baseUrl/products',
    ).replace(queryParameters: queryParameters);

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PaginatedProductsResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load products. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // --- FUNGSI BARU UNTUK CRUD PRODUK ---

  Future<Map<String, dynamic>> addProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(productData),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(productData),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> deleteProduct(
    String token,
    int productId,
  ) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return json.decode(response.body);
    }
    return {'success': true, 'message': 'Product deleted successfully'};
  }

  //=====================//
  // --- Transaction --- //
  //=====================//

  Future<Map<String, dynamic>> getTransactions(
    String token, {
    int page = 1,
    String search = '',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final uri = Uri.parse('$_baseUrl/transactions').replace(
      queryParameters: {
        'page': page.toString(),
        'search': search,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  // FUNGSI BARU: Checkout / Membuat transaksi baru
  Future<Map<String, dynamic>> createTransaction(
    String token,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'items': items}),
    );
    return json.decode(response.body);
  }

  //=====================//
  // ---    Users    --- //
  //=====================//

  Future<PaginatedUserResponse> getUsers(
    String token, {
    int page = 1,
    String? search,
    String? role,
  }) async {
    final queryParameters = {
      'page': page.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null && role.isNotEmpty) 'role': role,
    };

    final uri = Uri.parse(
      '$_baseUrl/users',
    ).replace(queryParameters: queryParameters);

    // DIUBAH: Header didefinisikan langsung
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return PaginatedUserResponse.fromJson(response.body);
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  /// GET: Mengambil detail satu user
  Future<User> getUserDetails(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      // DIUBAH: Header didefinisikan langsung
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromMap(jsonResponse['data']);
    } else {
      throw Exception('Failed to load user details: ${response.body}');
    }
  }

  /// POST: Membuat user baru (sebelumnya addUser) - Admin only
  Future<User> createUser(
    String token, {
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      // DIUBAH: Header didefinisikan langsung
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return User.fromMap(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        'Failed to create user: ${errorBody['message'] ?? response.body}',
      );
    }
  }

  /// PUT: Mengupdate user
  Future<User> updateUser(
    String token,
    int userId, {
    String? name,
    String? email,
    String? password,
    String? role, // Hanya admin yang bisa mengubah role
  }) async {
    final Map<String, String> body = {};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;

    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      // DIUBAH: Header didefinisikan langsung
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromMap(jsonResponse['data']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        'Failed to update user: ${errorBody['message'] ?? response.body}',
      );
    }
  }

  /// DELETE: Menghapus user - Admin only
  Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      // DIUBAH: Header didefinisikan langsung
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    // Sukses jika status code 200 (OK) atau 204 (No Content)
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}
