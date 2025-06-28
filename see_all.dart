import 'package:flutter/material.dart';
import 'add_to_cart.dart';

class FoodDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final List<Map<String, String>> items;
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) addToCart;
  final Function(Map<String, dynamic>, int) adjustQuantity;

  FoodDetailScreen({
    required this.categoryTitle,
    required this.items,
    required this.cartItems,
    required this.addToCart,
    required this.adjustQuantity,
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      appBar: AppBar(
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
                )),
            Text(
              widget.categoryTitle,
              style: TextStyle(
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
                            Navigator.pop(
                                context); // Pop back to FoodDetailScreen
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
        backgroundColor: Colors.green,
        elevation: 20,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65, // Adjusted for better fit
                  ),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return buildFoodCard(item);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFoodCard(Map<String, String> item) {
    final cartItem = widget.cartItems.firstWhere(
          (cartItem) => cartItem['name'] == item['name'],
      orElse: () => {},
    );
    int quantity = cartItem.isNotEmpty ? cartItem['quantity'] as int : 0;

    return SizedBox(
      height: 250,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max, // prevent overflow
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    item['name']!,
                    maxLines: 1,                        // ✅ Limit to one line
                    overflow: TextOverflow.ellipsis,   // ✅ Show "..."
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Rs.${item['price']}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (quantity > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 18),
                          onPressed: () {
                            setState(() {
                              widget.adjustQuantity({'name': item['name']}, -1);
                            });
                          },
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: Icon(Icons.add, size: 18),
                          onPressed: () {
                            setState(() {
                              widget.adjustQuantity({'name': item['name']}, 1);
                            });
                          },
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.addToCart({
                            'name': item['name'],
                            'image': item['image'],
                            'price': item['price'],
                            'discountedPrice': item['price'],
                            'quantity': 1,
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size(0, 30),
                      ),
                      child: Text("Add to Cart", style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
