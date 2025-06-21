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
  late List<Map<String, String>> _localFavoriteItems;

  @override
  void initState() {
    super.initState();
    // Create a local copy of favoriteItems to modify
    _localFavoriteItems = List.from(widget.favoriteItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.green,
      ),
      body: _localFavoriteItems.isEmpty
          ? Center(
        child: Text(
          'No favorite items yet!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: _localFavoriteItems.length,
        itemBuilder: (context, index) {
          final item = _localFavoriteItems[index];
          return ListTile(
            leading: Image.asset(item['image']!, width: 50, height: 50),
            title: Text(item['name']!),
            subtitle: Text("Rs. ${item['price']}"),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  // Remove item from local list
                  _localFavoriteItems.removeAt(index);
                  // Notify HomePage to update its state
                  widget.onRemoveFavorite(item['name']!);
                });
              },
            ),
          );
        },
      ),
    );
  }
}