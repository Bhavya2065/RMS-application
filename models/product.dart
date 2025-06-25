class Product {
  final String name;
  final String image;
  final String price;
  final String description;
  final String discount;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.discount,
  });

  double get discountedPrice {
    double originalPrice = double.parse(price);
    double discountPercentage = double.parse(discount);
    return originalPrice * (1 - discountPercentage / 100);
  }
}