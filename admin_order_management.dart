import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({super.key});

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> with SingleTickerProviderStateMixin {
  // Local list to store orders for UI display
  List<Map<String, dynamic>> _displayOrders = [];
  // List to track hidden order IDs
  List<String> _hiddenOrderIds = [];
  // TabController for managing tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> fetchAllOrders() {
    return FirebaseFirestore.instance
        .collectionGroup('orders')
        .orderBy('arrivalTime', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['documentId'] = doc.id;
      data['userId'] = doc.reference.parent.parent?.id ?? 'unknown_user';
      data['documentRef'] = doc.reference;
      return data;
    }).toList());
  }

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      final menuSnapshot = await FirebaseFirestore.instance.collection('menu_items').get();
      return menuSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching menu items: $e');
      return [];
    }
  }

  Future<String> fetchUsername(String userId) async {
    try {
      if (userId == 'unknown_user') return 'Unknown';
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data()?['username'] ?? 'Unknown';
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown';
    }
  }

  void _addItem(DocumentReference orderRef, List<Map<String, dynamic>> cartItems, List<Map<String, dynamic>> menuItems) async {
    // Get names of items already in cart
    final existingNames = cartItems.map((item) => item['name']?.toString().toLowerCase()).toSet();

    // Filter out already added items
    final availableItems = menuItems.where((item) {
      final name = item['name']?.toString().toLowerCase();
      return name != null && !existingNames.contains(name);
    }).toList();

    if (availableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All items already added to cart')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: DropdownButton<Map<String, dynamic>>(
          hint: const Text('Select Item'),
          isExpanded: true,
          items: availableItems.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item['name'] ?? 'Unknown'),
          )).toList(),
          onChanged: (selectedItem) async {
            if (selectedItem != null) {
              Navigator.pop(context);
              final updatedCart = List<Map<String, dynamic>>.from(cartItems)
                ..add({
                  'name': selectedItem['name'],
                  'quantity': 1,
                  'price': selectedItem['price']
                });
              await _updateOrder(orderRef, updatedCart);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(DocumentReference orderRef, List<Map<String, dynamic>> cartItems, int index, int newQuantity) async {
    if (newQuantity > 0) {
      final updatedCart = List<Map<String, dynamic>>.from(cartItems);
      updatedCart[index]['quantity'] = newQuantity;
      await _updateOrder(orderRef, updatedCart);
    }
  }

  void _deleteItem(DocumentReference orderRef, List<Map<String, dynamic>> cartItems, int index) async {
    final updatedCart = List<Map<String, dynamic>>.from(cartItems)..removeAt(index);
    await _updateOrder(orderRef, updatedCart);
  }

  Future<void> _updateOrder(DocumentReference orderRef, List<Map<String, dynamic>> cartItems) async {
    final total = cartItems.fold(0.0, (sum, item) => sum + (double.tryParse(item['price']?.toString() ?? '0') ?? 0) * (item['quantity'] ?? 1));
    await orderRef.update({
      'cartItems': cartItems,
      'totalAmount': total,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order updated')));
  }

  void _removeOrderFromUI(String documentId) {
    setState(() {
      _hiddenOrderIds.add(documentId);
      _displayOrders.removeWhere((order) => order['documentId'] == documentId);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order removed from view')));
  }

  Future<void> _updateStatus(DocumentReference orderRef, String currentStatus) async {
    final newStatus = currentStatus == 'pending' ? 'confirmed' : currentStatus == 'confirmed' ? 'completed' : 'pending';
    await orderRef.update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${_capitalize(newStatus)}')));
  }

  // Helper function to capitalize the first letter of a string
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchAllOrders(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderSnapshot.hasError || orderSnapshot.data == null) {
            return const Center(child: Text('Error loading orders. Check logs for details.'));
          }

          // Update display orders, filtering out hidden orders
          _displayOrders = orderSnapshot.data!.where((order) => !_hiddenOrderIds.contains(order['documentId'])).toList();

          // Filter orders by status for each tab
          final pendingOrders = _displayOrders.where((order) => order['status'] == 'pending').toList();
          final confirmedOrders = _displayOrders.where((order) => order['status'] == 'confirmed').toList();
          final completedOrders = _displayOrders.where((order) => order['status'] == 'completed').toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchMenuItems(),
            builder: (context, menuSnapshot) {
              if (menuSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final menuItems = menuSnapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: [
                  // Pending Orders Tab
                  _buildOrderList(pendingOrders, menuItems),
                  // Confirmed Orders Tab
                  _buildOrderList(confirmedOrders, menuItems),
                  // Completed Orders Tab
                  _buildOrderList(completedOrders, menuItems),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, List<Map<String, dynamic>> menuItems) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderRef = order['documentRef'] as DocumentReference? ??
            FirebaseFirestore.instance.collection('users').doc(order['userId']).collection('orders').doc(order['documentId']);
        final cartItems = List<Map<String, dynamic>>.from(order['cartItems'] ?? []);
        final timeStamp = order['arrivalTime'] as Timestamp?;
        final orderTimeStamp = order['orderTime'] as Timestamp?;
        final arrivalTime = timeStamp != null ? DateFormat('hh:mm a').format(timeStamp.toDate()) : 'N/A';
        final orderDate = orderTimeStamp != null ? DateFormat('dd/MM/yyyy hh:mm a').format(orderTimeStamp.toDate()) : 'N/A';
        final tableNumber = order['tableNumber'] ?? 'N/A';
        final total = order['totalAmount'] ?? 0.0;
        final status = order['status'] ?? 'pending'; // Use lowercase default
        final userId = order['userId'] ?? '';

        return FutureBuilder<String>(
          future: fetchUsername(userId),
          builder: (context, usernameSnapshot) {
            if (usernameSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final username = usernameSnapshot.data ?? 'Unknown';

            if (username == 'Unknown') {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Table: $tableNumber',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Status: ${_capitalize(status)}',
                          style: TextStyle(
                            color: status == 'pending' ? Colors.orange : status == 'confirmed' ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Username: $username'),
                    Text('Arrival Time: $arrivalTime'),
                    Text('Order Date: $orderDate'),
                    const SizedBox(height: 8),
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...cartItems.asMap().entries.map((entry) {
                      final item = entry.value;
                      final i = entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('- ${item['name'] ?? 'No name'} x${item['quantity'] ?? 1}')),
                            Text('₹${(double.tryParse(item['price']?.toString() ?? '0') ?? 0) * (item['quantity'] ?? 1)}'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => _updateQuantity(orderRef, cartItems, i, (item['quantity'] ?? 1) - 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => _updateQuantity(orderRef, cartItems, i, (item['quantity'] ?? 1) + 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => _deleteItem(orderRef, cartItems, i),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton.icon(
                          onPressed: () => _updateStatus(orderRef, status),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Change Status'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: status == 'completed'
                              ? null
                              : () => _addItem(orderRef, cartItems, menuItems),
                          icon: Icon(Icons.add, size: 20, color: status == 'completed' ? Colors.grey : Colors.green),
                          label: Text(
                            'Add Item',
                            style: TextStyle(
                              color: status == 'completed' ? Colors.grey : Colors.green,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _removeOrderFromUI(order['documentId']),
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          label: const Text(
                            'Delete Order',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}