import 'dart:convert';
import 'user.dart';

class PaginatedUserResponse {
  final List<User> users;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedUserResponse({
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedUserResponse.fromMap(Map<String, dynamic> map) {
    // Data dari Laravel ada di dalam nested object 'data'
    var data = map['data'];
    return PaginatedUserResponse(
      users: List<User>.from(data['data']?.map((x) => User.fromMap(x))),
      currentPage: data['current_page']?.toInt() ?? 0,
      lastPage: data['last_page']?.toInt() ?? 0,
      total: data['total']?.toInt() ?? 0,
    );
  }

  factory PaginatedUserResponse.fromJson(String source) =>
      PaginatedUserResponse.fromMap(json.decode(source));
}
