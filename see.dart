import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  final String categoryTitle;
  final List<Map<String, String>> items;

  FoodDetailScreen({required this.categoryTitle, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF), // Subtle background color
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
                  color: Colors.white,
                )),
            Text(
              categoryTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ))
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 20,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items per row
            crossAxisSpacing: 16, // Horizontal spacing
            mainAxisSpacing: 16, // Vertical spacing
            childAspectRatio: 0.71, // Adjust to make items look proportionate
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return buildFoodCard(item);
          },
        ),
      ),
    );
  }

  Widget buildFoodCard(Map<String, String> item) {
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
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              item['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150, // Height for the image
            ),
          ),
          SizedBox(height: 8), // Space below the image
          Text(
            item['name']!,
            textAlign: TextAlign.center, // Center align text
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8), // Space below the name
          Text(
            'Rs.${item['price']}.00',
            textAlign: TextAlign.center, // Center align text
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Add to Cart functionality
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
    );
  }
}
