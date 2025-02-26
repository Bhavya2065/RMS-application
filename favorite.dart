import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  final List<Map<String, String>> favoriteItems;
  final Function(String) onRemoveFavorite; // Callback function

  const FavoritePage({
    super.key,
    required this.favoriteItems,
    required this.onRemoveFavorite, // Accept callback
  });

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.green,
      ),
      body: widget.favoriteItems.isEmpty
          ? Center(
        child: Text(
          'No favorite items yet!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: widget.favoriteItems.length,
        itemBuilder: (context, index) {
          final item = widget.favoriteItems[index];
          return ListTile(
            leading: Image.asset(item['image']!, width: 50, height: 50),
            title: Text(item['name']!),
            subtitle: Text("Rs. ${item['price']}"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  widget.onRemoveFavorite(item['name']!); // Notify HomePage
                });
              },
            ),
          );
        },
      ),
    );
  }
}
