import 'package:flutter/material.dart';
import 'add_to_cart.dart'; // Import AddToCartPage

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
                            Navigator.pop(context); // Pop back to FoodDetailScreen
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 2, // optional responsive tweak
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.63,
                ),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return buildFoodCard(item);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildFoodCard(Map<String, String> item) {
    final cartItem = widget.cartItems.firstWhere(
          (cartItem) => cartItem['name'] == item['name'],
      orElse: () => {},
    );
    int quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 7,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(), // disables scroll inside card
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      item['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    item['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rs.${item['price']}.00',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  quantity > 0
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.adjustQuantity({'name': item['name']}, -1);
                          });
                        },
                        icon: Icon(Icons.remove, color: Colors.black),
                      ),
                      Text('$quantity', style: TextStyle(color: Colors.black)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.adjustQuantity({'name': item['name']}, 1);
                          });
                        },
                        icon: Icon(Icons.add, color: Colors.black),
                      ),
                    ],
                  )
                      : ElevatedButton(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}