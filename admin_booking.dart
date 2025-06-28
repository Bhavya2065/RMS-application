import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  late Future<List<Map<String, dynamic>>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = fetchAllBookings();
  }

  Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> combinedBookings = [];

    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userName = userDoc.data()['username'] ?? 'Unknown';
      final userEmail = userDoc.data()['email'] ?? 'Unknown';

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('orderTime', descending: true)
          .get();

      for (final orderDoc in ordersSnapshot.docs) {
        final bookingData = orderDoc.data();
        bookingData['userName'] = userName;
        bookingData['userEmail'] = userEmail;
        bookingData['documentRef'] = orderDoc.reference;
        combinedBookings.add(bookingData);
      }
    }

    return combinedBookings;
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
        title: const Text('Bookings'),
        backgroundColor: Colors.green,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final cartItems = List<Map<String, dynamic>>.from(booking['cartItems']);
              final time = (booking['arrivalTime'] as Timestamp).toDate();
              final documentRef = booking['documentRef'] as DocumentReference;
              final currentStatus = booking['status'];
              final isCompleted = currentStatus == 'completed';

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
                        children: [
                          const Icon(Icons.person, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['userName'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['userEmail'] ?? 'N/A',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.table_restaurant, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('Table: ${booking['tableNumber']}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.group, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('People: ${booking['numberOfPersons']}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('Time: ${DateFormat('hh:mm a').format(time)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text(
                          '• ${item['name']} x${item['quantity']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      )),
                      const SizedBox(height: 8),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          isCompleted
                              ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _capitalize(currentStatus),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              : DropdownButton<String>(
                            value: currentStatus,
                            items: ['pending', 'confirmed', 'completed']
                                .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                _capitalize(status),
                                style: TextStyle(
                                  color: status == 'pending'
                                      ? Colors.orange
                                      : status == 'confirmed'
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                              ),
                            ))
                                .toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null && newStatus != currentStatus) {
                                await documentRef.update({'status': newStatus});
                                setState(() {
                                  bookings[index]['status'] = newStatus;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Status updated to ${_capitalize(newStatus)}')),
                                );
                              }
                            },
                            style: const TextStyle(fontSize: 14),
                            underline: Container(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.green[700],
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