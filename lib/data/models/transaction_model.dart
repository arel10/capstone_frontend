import 'package:transaksi/data/models/product_model.dart';
import 'package:transaksi/data/models/user.dart';

class PaginatedTransactionsResponse {
  final List<Transaction> transactions;
  final int currentPage;
  final int lastPage;

  PaginatedTransactionsResponse({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedTransactionsResponse.fromJson(Map<String, dynamic> json) {
    var transactionList = (json['data']['data'] as List)
        .map((i) => Transaction.fromJson(i))
        .toList();

    return PaginatedTransactionsResponse(
      transactions: transactionList,
      currentPage: json['data']['current_page'],
      lastPage: json['data']['last_page'],
    );
  }
}

class Transaction {
  final int id;
  final int userId;
  final num totalAmount;
  final String status;
  final String? paymentUrl; // Snap Token
  final String? midtransBookingCode;
  final String createdAt;
  final User? user;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    this.paymentUrl,
    this.midtransBookingCode,
    required this.createdAt,
    this.user,
    required this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: num.tryParse(json['total_amount'].toString()) ?? 0,
      status: json['status'],
      paymentUrl: json['payment_url'],
      midtransBookingCode: json['midtrans_booking_code'],
      createdAt: json['created_at'],
      user: json['user'] != null ? User.fromMap(json['user']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((i) => TransactionItem.fromJson(i))
                .toList()
          : [],
    );
  }
}

class TransactionItem {
  final int id;
  final int productId;
  final String productName;
  final num price;
  final int quantity;
  final Product? product;

  TransactionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.product,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      price: num.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}
