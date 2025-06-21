import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'add_to_cart.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) addToCart;
  final Function(Map<String, dynamic>, int) adjustQuantity;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.cartItems,
    required this.addToCart,
    required this.adjustQuantity,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for "Add to Cart" button
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItem = widget.cartItems.firstWhere(
          (cartItem) => cartItem['name'] == widget.product['name'],
      orElse: () => {},
    );
    int quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;
    double totalPrice = quantity * double.parse(widget.product['discountedPrice'].toString());

    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 20,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
            Text(
              widget.product['name'],
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddToCartPage(
                          cartItems: widget.cartItems,
                          onNavigateBack: (int index) {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                ),
                if (widget.cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.cartItems.fold<int>(0, (sum, item) => sum + ((item["quantity"] ?? 0) as int))}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Zoom-In Feature
            Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.asset(
                          widget.product['image'] ?? 'assets/images/default.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // Improved Price Badge
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-${widget.product['discount']}%',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs.${widget.product['price']}.00',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs.${widget.product['discountedPrice']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.product['name'],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product['description'] ??
                  'No description available for this item.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Quantity Controller with Improved Design
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: quantity > 0
                          ? () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          widget.adjustQuantity({
                            'name': widget.product['name'],
                            'image': widget.product['image'],
                            'price': widget.product['price'],
                            'discountedPrice': widget.product['discountedPrice'],
                          }, -1);
                        });
                      }
                          : null,
                      icon: Icon(Icons.remove, color: Colors.black),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          widget.adjustQuantity({
                            'name': widget.product['name'],
                            'image': widget.product['image'],
                            'price': widget.product['price'],
                            'discountedPrice': widget.product['discountedPrice'],
                          }, 1);
                        });
                      },
                      icon: Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // "Add to Cart" Button with Animation and Total Price
            Center(
              child: GestureDetector(
                onTapDown: (_) {
                  _animationController.forward();
                },
                onTapUp: (_) {
                  _animationController.reverse();
                  if (quantity > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${widget.product['name']} added to the cart (x$quantity)'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onTapCancel: () {
                  _animationController.reverse();
                },
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 40,
                        ),
                        decoration: BoxDecoration(
                          color: quantity > 0 ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Add to Cart${quantity > 0 ? ' (Rs. ${totalPrice.toStringAsFixed(2)})' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}