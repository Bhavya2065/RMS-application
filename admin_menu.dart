import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMenuPage extends StatefulWidget {
  const ManageMenuPage({super.key});

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No menu items found.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              return ListTile(
                leading: item['imageUrl'] != null
                    ? Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood),
                title: Text(item['name'] ?? 'No Name'),
                subtitle: Text('${item['category']} • ₹${item['price']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(item.id),
                ),
                onTap: () => _showAddOrEditDialog(existingItem: item),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteItem(String id) async {
    await FirebaseFirestore.instance.collection('menu_items').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted')),
    );
  }

  void _showAddOrEditDialog({DocumentSnapshot? existingItem}) {
    final nameController = TextEditingController(text: existingItem?['name']);
    final priceController = TextEditingController(text: existingItem?['price']?.toString());
    final descriptionController = TextEditingController(text: existingItem?['description']);
    final categoryController = TextEditingController(text: existingItem?['category']);
    final discountController = TextEditingController(text: existingItem?['discount']?.toString());
    final imageUrlController = TextEditingController(text: existingItem?['imageUrl']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingItem == null ? 'Add Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: discountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount')),
              TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final discount = int.tryParse(discountController.text.trim()) ?? 0;

              if (name.isEmpty) return;

              final itemData = {
                'name': name,
                'price': price,
                'description': descriptionController.text.trim(),
                'category': categoryController.text.trim(),
                'discount': discount,
                'imageUrl': imageUrlController.text.trim(),
              };

              if (existingItem == null) {
                await FirebaseFirestore.instance.collection('menu_items').add(itemData);
              } else {
                await FirebaseFirestore.instance.collection('menu_items').doc(existingItem.id).update(itemData);
              }

              Navigator.pop(context);
            },
            child: Text(existingItem == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }
}
