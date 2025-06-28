import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rms_application/admin_booking.dart';
import 'package:rms_application/admin_menu.dart';
import 'package:rms_application/sign_in.dart';
import 'admin_feedback.dart';
import 'admin_order_management.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Logout'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adaptive column count based on screen width
          int crossAxisCount = constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 600
              ? 3
              : 2;

          // Adaptive spacing and padding
          double adaptivePadding = constraints.maxWidth > 800 ? 32 : 16;
          double adaptiveSpacing = constraints.maxWidth > 800 ? 24 : 12;

          return GridView.builder(
            padding: EdgeInsets.all(adaptivePadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: adaptiveSpacing,
              mainAxisSpacing: adaptiveSpacing,
              childAspectRatio: 1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final tiles = [
                {
                  'title': 'Manage Menu',
                  'icon': Icons.restaurant_menu,
                  'page': const ManageMenuPage(),
                },
                {
                  'title': 'View Orders',
                  'icon': Icons.receipt_long,
                  'page': const ViewOrdersPage(),
                },
                {
                  'title': 'Feedback',
                  'icon': Icons.feedback,
                  'page': const AdminFeedbackPage(),
                },
                {
                  'title': 'Bookings',
                  'icon': Icons.event_seat,
                  'page': const AdminBookingPage(),
                },
              ];

              final tile = tiles[index];
              return _buildTile(
                context,
                tile['title'] as String,
                tile['icon'] as IconData,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => tile['page'] as Widget),
                ),
              );
            },
          );
        },
      ),
    );
  }
}