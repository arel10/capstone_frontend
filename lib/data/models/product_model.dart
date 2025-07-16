class Product {
  final int id;
  final String name;
  final String? description;
  final num price;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: num.tryParse(json['price'].toString()) ?? 0,
      stock: json['stock'],
      imageUrl: json['image_url'],
    );
  }
}

// Model parsing respons paginasi dari API
class PaginatedProductsResponse {
  final List<Product> products;
  final int lastPage;

  PaginatedProductsResponse({required this.products, required this.lastPage});

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json) {
    var productList = (json['data'] as List)
        .map((i) => Product.fromJson(i))
        .toList();

    return PaginatedProductsResponse(
      products: productList,
      lastPage: json['pagination']['last_page'],
    );
  }
}
