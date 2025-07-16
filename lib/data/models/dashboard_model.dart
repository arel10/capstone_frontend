import 'package:intl/intl.dart';

// Model Utama
class DashboardData {
  final Summary summary;
  final Map<String, int> transactionsByStatus;
  final List<RecentTransaction> recentTransactions;
  final List<MonthlyData> monthlyData;
  // TopProduct, FavoriteProduct, tergantung role
  final List<dynamic> products;

  DashboardData({
    required this.summary,
    required this.transactionsByStatus,
    required this.recentTransactions,
    required this.monthlyData,
    required this.products,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json, String role) {
    // Logika parsing
    Map<String, int> statusMap = {};
    final statusData = json['transactions_by_status'];
    if (statusData is Map<String, dynamic>) {
      statusMap = statusData.map((key, value) => MapEntry(key, value as int));
    }

    var summary = Summary.fromJson(json['summary']);
    var recent = (json['recent_transactions'] as List)
        .map((i) => RecentTransaction.fromJson(i))
        .toList();

    var monthlyKey = role == 'admin' ? 'monthly_revenue' : 'monthly_spending';
    var monthly = (json[monthlyKey] as List)
        .map((i) => MonthlyData.fromJson(i))
        .toList();

    var productsKey = role == 'admin' ? 'top_products' : 'favorite_products';
    var productsList = (json[productsKey] as List).map((i) {
      return role == 'admin'
          ? TopProduct.fromJson(i)
          : FavoriteProduct.fromJson(i);
    }).toList();

    return DashboardData(
      summary: summary,
      transactionsByStatus: statusMap,
      recentTransactions: recent,
      monthlyData: monthly,
      products: productsList,
    );
  }
}

// Model Summary
class Summary {
  final int? totalUsers;
  final int? totalProducts;
  final int totalTransactions;
  final num totalRevenue;
  final num? totalSpent;

  Summary({
    this.totalUsers,
    this.totalProducts,
    required this.totalTransactions,
    required this.totalRevenue,
    this.totalSpent,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalUsers: json['total_users'],
      totalProducts: json['total_products'],
      totalTransactions: json['total_transactions'] ?? 0,
      totalRevenue: num.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0,
      totalSpent: num.tryParse(json['total_spent']?.toString() ?? '0'),
    );
  }
}

// Model Pendapatan dan pengeluaran bulanan
class MonthlyData {
  final int year;
  final int month;
  final num total;
  String get monthName => DateFormat.MMM().format(DateTime(year, month));

  MonthlyData({required this.year, required this.month, required this.total});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      year: int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      month: int.tryParse(json['month']?.toString() ?? '0') ?? 0,
      total: num.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

// Model transaksi Terbaru
class RecentTransaction {
  final int id;
  final String status;
  final num totalAmount;
  final String createdAt;
  final UserTransaction user;

  RecentTransaction({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.user,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'],
      status: json['status'],
      totalAmount: num.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'],
      user: UserTransaction.fromJson(json['user'] ?? {}),
    );
  }
}

class UserTransaction {
  final String name;
  UserTransaction({required this.name});
  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    return UserTransaction(name: json['name'] ?? 'Unknown User');
  }
}

// Model produk terlaris (admin)
class TopProduct {
  final String name;
  final int totalSold;
  final num totalRevenue;

  TopProduct({
    required this.name,
    required this.totalSold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'],
      totalSold: int.tryParse(json['total_sold']?.toString() ?? '0') ?? 0,
      totalRevenue: num.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0,
    );
  }
}

// Model produk favorit (user)
class FavoriteProduct {
  final String name;
  final String? imageUrl;
  final int totalBought;

  FavoriteProduct({
    required this.name,
    this.imageUrl,
    required this.totalBought,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      name: json['name'],
      imageUrl: json['image_url'],
      totalBought: int.tryParse(json['total_bought']?.toString() ?? '0') ?? 0,
    );
  }
}
