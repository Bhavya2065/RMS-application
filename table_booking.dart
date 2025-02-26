import 'package:flutter/material.dart';
import 'package:rms_application/order_confirmation.dart';

class TableBookingPage extends StatefulWidget {
  const TableBookingPage({super.key});

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
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  int getTotalCapacity() {
    return selectedTables.fold(
        0, (sum, table) => sum + tableCapacities[table]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book a Table"),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Number of People",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed: _peopleCount > 1
                      ? () => setState(() => _peopleCount--)
                      : null,
                ),
                Text("$_peopleCount",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.greenAccent),
                  onPressed: () => setState(() => _peopleCount++),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Select Dining Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: EdgeInsets.all(15),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.access_time, color: Colors.green.shade500),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Choose Your Table",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 20, color: Colors.redAccent),
                SizedBox(width: 5),
                Text("Booked Table"),
                SizedBox(width: 20),
                Container(width: 20, height: 20, color: Colors.blueAccent),
                SizedBox(width: 5),
                Text("Available Table"),
                SizedBox(width: 20),
                Container(width: 20, height: 20, color: Colors.greenAccent),
                SizedBox(width: 5),
                Text("Selected Table"),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: tableCapacities.length,
                itemBuilder: (context, index) {
                  int tableNumber = index + 1;
                  bool isBooked = bookedTables.contains(tableNumber);
                  bool isSelected = selectedTables.contains(tableNumber);
                  return GestureDetector(
                    onTap: isBooked
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                selectedTables.remove(tableNumber);
                              } else if (getTotalCapacity() < _peopleCount) {
                                selectedTables.add(tableNumber);
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Table $tableNumber",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text("${tableCapacities[tableNumber]} people",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedTables.isNotEmpty) ...[
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Total Tables: ${selectedTables.length} | Total People: ${getTotalCapacity()}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade500),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: selectedTables.isEmpty ||
                          _selectedTime == null ||
                          getTotalCapacity() < _peopleCount
                      ? null
                      : () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OrderConfirmationPage()));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Confirm Booking",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
