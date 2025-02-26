import 'package:flutter/material.dart';
import 'package:rms_application/settings.dart';

class ProfilePage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const ProfilePage({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFEAF1DF),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // onPressed: () {
          //   if (widget.onTabChange != null) {
          //     widget.onTabChange!(0); // Ensure navigation back to Home tab
          //   }
          //   Navigator.pop(context);
          // },
          onPressed: () {
            Navigator.pop(context);
            widget.onTabChange(0); // Notify Home tab is selected
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.person, // User icon instead of image
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User Name
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // User Email
                  const Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            // Profile Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  buildProfileOption(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {
                      // Navigate to Edit Profile
                    },
                  ),
                  buildProfileOption(
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      // Navigate to Order History
                    },
                  ),
                  buildProfileOption(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()));
                    },
                  ),
                  buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // Navigate to Help & Support
                    },
                  ),
                  buildProfileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      // Logic to log out
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFEAF1DF),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Color(0xFFEAF1DF),
      //   currentIndex: widget.selectedIndex,
      //   onTap: (index) {
      //     if (index == widget.selectedIndex) return; // Prevent redundant navigation
      //     widget.onTabChange(index); // Notify parent about tab change
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

  Widget buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onTap,
        ),
      ),
    );
  }
}
