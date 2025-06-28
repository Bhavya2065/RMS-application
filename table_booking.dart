import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'order_confirmation.dart';

class TableBookingPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double gst;
  final double total;

  const TableBookingPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.gst,
    required this.total,
  });

  @override
  _TableBookingPageState createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  int _peopleCount = 2;
  TimeOfDay? _selectedTime;
  List<int> bookedTables = [3, 5, 7];
  Map<int, int> tableCapacities = {
    1: 2,
    2: 4,
    3: 2,
    4: 6,
    5: 5,
    6: 4,
    7: 2,
    8: 8,
    9: 3,
    10: 4,
    11: 6,
    12: 2
  };
  List<int> selectedTables = [];

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final currentTime =
      DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final startTime =
      DateTime(now.year, now.month, now.day, 11, 0);
      final endTime = DateTime(now.year, now.month, now.day, 24, 0);
      if (selectedDateTime.isAfter(currentTime) &&
          selectedDateTime.isAfter(startTime) &&
          selectedDateTime.isBefore(endTime)) {
        setState(() {
          _selectedTime = pickedTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(selectedDateTime.isAfter(currentTime)
                  ? "Please select a time between 11:00 AM and 12:00 PM"
                  : "Please select a time after the current time")),
        );
      }
    }
  }

  int getTotalCapacity() {
    return selectedTables.fold(
        0, (sum, table) => sum + (tableCapacities[table] ?? 0));
  }

  bool hasSufficientCapacity() {
    int totalAvailableCapacity = tableCapacities.entries
        .where((entry) => !bookedTables.contains(entry.key))
        .fold(0, (sum, entry) => sum + entry.value);
    return _peopleCount <= totalAvailableCapacity;
  }

  bool canAddTable(int tableNumber) {
    final newCapacity =
        getTotalCapacity() + (tableCapacities[tableNumber] ?? 0);
    return newCapacity <= _peopleCount + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Table"),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Number of People",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.redAccent),
                              onPressed: _peopleCount > 1
                                  ? () => setState(() => _peopleCount--)
                                  : null,
                            ),
                            Text("$_peopleCount",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.greenAccent),
                              onPressed: () => setState(() => _peopleCount++),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Select Dining Time",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedTime == null
                                      ? "Select Time"
                                      : _selectedTime!.format(context),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.access_time,
                                    color: Colors.green.shade500),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Choose Your Table",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    color: Colors.redAccent),
                                const SizedBox(width: 5),
                                const Text("Booked Table"),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 5),
                                const Text("Available Table"),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    color: Colors.greenAccent),
                                const SizedBox(width: 5),
                                const Text("Selected Table"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: tableCapacities.length,
                            itemBuilder: (context, index) {
                              int tableNumber = index + 1;
                              bool isBooked =
                              bookedTables.contains(tableNumber);
                              bool isSelected =
                              selectedTables.contains(tableNumber);
                              return GestureDetector(
                                onTap: isBooked
                                    ? () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Table $tableNumber is already booked")),
                                  );
                                }
                                    : () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedTables.remove(tableNumber);
                                    } else if (canAddTable(tableNumber)) {
                                      selectedTables.add(tableNumber);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Table $tableNumber exceeds required capacity")),
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? Colors.redAccent
                                        : (isSelected
                                        ? Colors.greenAccent
                                        : Colors.blueAccent),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text("Table $tableNumber",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "${tableCapacities[tableNumber]} people",
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (!hasSufficientCapacity()) ...[
                          const SizedBox(height: 10),
                          const Text(
                            "Not enough tables available for this group size",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        if (selectedTables.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Total Tables: ${selectedTables.length} | Total People: ${getTotalCapacity()}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade500),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: selectedTables.isEmpty ||
                                  _selectedTime == null ||
                                  getTotalCapacity() < _peopleCount
                                  ? null
                                  : () async {
                                await storeOrderToFirestore(
                                  cartItems: widget.cartItems,
                                  tableNumber: selectedTables.first,
                                  numberOfPersons: _peopleCount,
                                  arrivalTime: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    _selectedTime!.hour,
                                    _selectedTime!.minute,
                                  ),
                                  totalAmount: widget.total,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrderConfirmationPage(
                                          peopleCount: _peopleCount,
                                          selectedTime: _selectedTime!,
                                          selectedTables: selectedTables,
                                          cartItems: widget.cartItems,
                                          subtotal: widget.subtotal,
                                          gst: widget.gst,
                                          total: widget.total,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade500,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                              ),
                              child: const Text("Confirm Booking",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> storeOrderToFirestore({
  required List<Map<String, dynamic>> cartItems,
  required int tableNumber,
  required int numberOfPersons,
  required DateTime arrivalTime,
  required double totalAmount,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final uid = user.uid;
    final uuid = Uuid();
    final orderId = uuid.v4(); // Generate unique orderId

    final usernameDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final username = usernameDoc.data()?['username'] ?? 'User';

    final orderData = {
      'uid': uid,
      'username': username,
      'cartItems': cartItems,
      'tableNumber': tableNumber,
      'numberOfPersons': numberOfPersons,
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'totalAmount': totalAmount,
      'status': 'pending',
      'orderTime': Timestamp.now(),
      'orderId': orderId, // Include orderId in the data
    };

    // Save to users/userId/orders with the generated orderId
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .set(orderData);
  }
}