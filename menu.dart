import 'package:flutter/material.dart';
import 'models/food_category.dart';

class MenuCardPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChange; // Callback to notify tab change

  const MenuCardPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  State<MenuCardPage> createState() => _MenuCardPageState();
}

class _MenuCardPageState extends State<MenuCardPage> {
  String? _selectedCategory;
  List<Map<String, String>> _filteredItems = [];
  final FocusNode _dropdownFocusNode = FocusNode(); // Add FocusNode for dropdown
  bool _isFocused = false; // Track focus state

  @override
  void initState() {
    super.initState();
    _dropdownFocusNode.addListener(() {
      setState(() {
        _isFocused = _dropdownFocusNode.hasFocus; // Update focus state
      });
    });
  }

  @override
  void dispose() {
    _dropdownFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFFEAF1DF),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            widget.onTabChange(0); // Notify Home tab is selected
          },
        ),
      ),
      body: Column(
        children: [
          // Dropdown for category selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              focusNode: _dropdownFocusNode, // Attach FocusNode
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Select Food Category',
                labelStyle: TextStyle(
                  color: _isFocused ? Colors.green : Colors.black54, // Change color
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
                  _filteredItems =
                      foodCategories[newValue] ?? []; // Update food items
                });
              },
            ),
          ),
          // Display the menu items for the selected category
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
      backgroundColor: const Color(0xFFEAF1DF),
      // bottomNavigationBar: BottomNavigationBar(
      //     backgroundColor: Color(0xFFEAF1DF),
      //   currentIndex: widget.selectedIndex,
      //   onTap: (index) {
      //     if (index == widget.selectedIndex) return; // Prevent redundant navigation
      //     widget.onTabChange(index); // Notify parent widget about tab change
      //   },
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Cart',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.menu_book),
      //       label: 'Menu',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.list_alt),
      //       label: 'Orders',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   selectedItemColor: Colors.green,
      //   unselectedItemColor: Colors.black54,
      //   type: BottomNavigationBarType.fixed,
      // ),
    );
  }

  Widget buildMenuItemCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item['image'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name
                    Text(
                      item['name'] ?? 'Unknown Food',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Food Price
                    Text(
                      '₹${item['price'] ?? '0'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
