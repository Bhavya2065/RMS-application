import 'package:flutter/material.dart';
import 'models/food_category.dart';
import 'models/product.dart';
import 'product_detail.dart'; // Import ProductDetailPage

class MenuCardPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  final List<Map<String, dynamic>> cartItems; // Add cartItems
  final Function(Map<String, dynamic>) addToCart; // Add addToCart
  final Function(Map<String, dynamic>, int) adjustQuantity; // Add adjustQuantity

  const MenuCardPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.cartItems, // Add to constructor
    required this.addToCart, // Add to constructor
    required this.adjustQuantity, // Add to constructor
  });

  @override
  State<MenuCardPage> createState() => _MenuCardPageState();
}

class _MenuCardPageState extends State<MenuCardPage> {
  String? _selectedCategory;
  List<Product> _filteredItems = [];
  final FocusNode _dropdownFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _dropdownFocusNode.addListener(() {
      setState(() {
        _isFocused = _dropdownFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _dropdownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            widget.onTabChange(0);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              focusNode: _dropdownFocusNode,
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Select Food Category',
                labelStyle: TextStyle(
                  color: _isFocused ? Colors.green : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
              items: foodCategories.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  _filteredItems = foodCategories[newValue] ?? [];
                  print('Selected category: $newValue');
                  print('Items in category: $_filteredItems');
                });
              },
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
              child: Text(
                _selectedCategory == null
                    ? 'Please select a category.'
                    : 'No food items available in this category.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return buildMenuItemCard(_filteredItems[index]);
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildMenuItemCard(Product item) {
    // Parse price and discount from String to double/int
    final double price = double.tryParse(item.price) ?? 0.0;
    final double discount = double.tryParse(item.discount) ?? 0.0;
    final double discountedPrice = item.discountedPrice;

    // Format the values for display
    final String priceText = '₹${price.toStringAsFixed(2)}';
    final String discountedPriceText = '₹${discountedPrice.toStringAsFixed(2)}';
    final String discountText = '${discount.toStringAsFixed(0)}% OFF';

    // Find the current quantity in the cart
    final cartItem = widget.cartItems.firstWhere(
          (cartItem) => cartItem['name'] == item.name,
      orElse: () => {},
    );
    final int quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

    return InkWell(
      // Add InkWell for tap handling
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: {
                'name': item.name,
                'image': item.image,
                'price': item.price,
                'description': item.description,
                'quantity': quantity.toString(),
                'discount': item.discount,
                'discountedPrice': item.discountedPrice.toStringAsFixed(2),
              },
              cartItems: widget.cartItems,
              addToCart: widget.addToCart,
              adjustQuantity: widget.adjustQuantity,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            priceText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            discountedPriceText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        discountText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}