import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rms_application/pdf_receipt.dart';

class OrderPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onTabChange;

  const OrderPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  Future<List<Map<String, dynamic>>>? _ordersFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('orderTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data(), 'docId': doc.id})
        .toList();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = fetchOrders();
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Future<void> cancelOrder(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Delete from users/uid/orders
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(docId)
          .delete();

      _refreshOrders(); // Refresh the order list after deletion

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Order cancelled and removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    }
  }

  void showCancelConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancellation'),
          content: const Text('Do you want to cancel the order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await cancelOrder(docId);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Your Orders'),
        backgroundColor: Colors.green,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            if (widget.onTabChange != null) {
              widget.onTabChange!(0);
            }
          },
        ),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!;
          final pendingOrders = orders.where((order) => order['status'] == 'pending').toList();
          final confirmedOrders = orders.where((order) => order['status'] == 'confirmed').toList();
          final completedOrders = orders.where((order) => order['status'] == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(pendingOrders),
              _buildOrderList(confirmedOrders),
              _buildOrderList(completedOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders found"));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final cartItems = order['cartItems'] as List<dynamic>;
        final arrivalTime = order['arrivalTime'] as Timestamp;
        final orderTime = order['orderTime'] as Timestamp;
        final docId = order['docId'] as String;
        final status = order['status'] ?? 'pending';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Date: ${formatTimestamp(orderTime)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("Table Number: ${order['tableNumber']}"),
                Text("People: ${order['numberOfPersons']}"),
                Text("Arrival: ${formatTimestamp(arrivalTime)}"),
                Text(
                  "Status: ${_capitalize(status)}",
                  style: TextStyle(
                    color: status == 'pending' ? Colors.orange : status == 'confirmed' ? Colors.blue : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Items:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (var item in cartItems)
                  Text(
                      "- ${item['name']} x${item['quantity']} @ ₹${item['price']}"),
                const SizedBox(height: 8),
                Text(
                  "Total: ₹${order['totalAmount'].toStringAsFixed(2)}",
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          final totalAmount =
                          (order['totalAmount'] as num).toDouble();
                          final gst = totalAmount * 0.18;
                          final subtotal = totalAmount - gst;

                          generateReceipt(
                            cartItems: order['cartItems'],
                            tableNumber: order['tableNumber'],
                            numberOfPersons: order['numberOfPersons'],
                            arrivalTime: (order['arrivalTime'] as Timestamp)
                                .toDate(),
                            subtotal: subtotal,
                            gst: gst,
                            total: totalAmount,
                            orderDate: (order['orderTime'] as Timestamp).toDate(),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text("Download Receipt"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final isComplete = status == 'completed';
                          final hasPassedArrival =
                          arrivalTime.toDate().isBefore(now);
                          final canCancel = !(isComplete && hasPassedArrival);

                          return TextButton.icon(
                            onPressed: canCancel
                                ? () => showCancelConfirmationDialog(context, docId)
                                : null,
                            icon: Icon(
                              Icons.cancel,
                              color: canCancel ? Colors.red : Colors.grey,
                            ),
                            label: Text(
                              "Cancel Order",
                              style: TextStyle(
                                color: canCancel ? Colors.red : Colors.grey,
                              ),
                            ),
                          );
                        },
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
  }
}