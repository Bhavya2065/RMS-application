import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rms_application/home.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Confirmation",
            style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildOrderDetails(),
            SizedBox(height: 20),
            _buildBookingDetails(),
            SizedBox(height: 20),
            _buildPaymentSummary(),
            SizedBox(height: 50),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 10),
          Text(
            "Thank You for Your Order!",
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text("Your order has been successfully placed.",
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return _buildCard(
      "Order Details",
      [
        "1x Margherita Pizza - Rs. 12.99",
        "2x Cheeseburgers - Rs. 15.99",
        "1x Soft Drink - Rs. 3.50",
      ],
      Icons.fastfood,
    );
  }

  Widget _buildBookingDetails() {
    return _buildCard(
      "Table Booking Details",
      [
        "Table No: 5",
        "Guests: 3",
        "Dining Time: 7:30 PM",
      ],
      Icons.event_seat,
    );
  }

  Widget _buildPaymentSummary() {
    return _buildCard(
      "Payment Summary",
      [
        "Subtotal: Rs. 32.48",
        "Tax: Rs. 2.50",
        "Total: Rs. 34.98",
        "Payment Method: Credit Card",
      ],
      Icons.payment,
    );
  }

  Widget _buildCard(String title, List<String> details, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                SizedBox(width: 10),
                Text(title,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Divider(),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(detail),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Use pop to return to the previous screen (FoodMenuScreen)
            Navigator.pop(context);
          },
          icon: Icon(Icons.home, color: Colors.white),
          label: Text("Back to Home", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade500),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.download, color: Colors.white),
          label: Text("Download Receipt", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
      ],
    );
  }
}
