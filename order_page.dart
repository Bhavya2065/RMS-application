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

class _OrderPageState extends State<OrderPage> {
  Future<List<Map<String, dynamic>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
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

    return snapshot.docs.map((doc) => {...doc.data(), 'docId': doc.id}).toList();
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
    print(FirebaseAuth.instance.currentUser?.uid);
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(docId)
          .delete();
      _refreshOrders(); // Refresh the order list after deletion

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled and removed successfully')),
      );
      _refreshOrders(); // Refresh the order list after deletion
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

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final cartItems = order['cartItems'] as List<dynamic>;
              final arrivalTime = order['arrivalTime'] as Timestamp;
              final orderTime = order['orderTime'] as Timestamp;
              final docId = order['docId'] as String;

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
                      Text("Order Date: ${formatTimestamp(orderTime)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Table Number: ${order['tableNumber']}"),
                      Text("People: ${order['numberOfPersons']}"),
                      Text("Arrival: ${formatTimestamp(arrivalTime)}"),
                      Text("Status: ${order['status']}"),
                      const SizedBox(height: 8),
                      const Text("Items:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var item in cartItems)
                        Text(
                            "- ${item['name']} x${item['quantity']} @ ₹${item['price']}"),
                      const SizedBox(height: 8),
                      Text("Total: ₹${order['totalAmount'].toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                final totalAmount = (order['totalAmount'] as num).toDouble();
                                final gst = totalAmount * 0.18;
                                final subtotal = totalAmount - gst;

                                generateReceipt(
                                  cartItems: order['cartItems'],
                                  tableNumber: order['tableNumber'],
                                  numberOfPersons: order['numberOfPersons'],
                                  arrivalTime: (order['arrivalTime'] as Timestamp).toDate(),
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
                          if (order['status'] != 'Cancelled')
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => showCancelConfirmationDialog(context, docId),
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                label: const Text(
                                  "Cancel Order",
                                  style: TextStyle(color: Colors.red),
                                ),
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
      ),
    );
  }
}