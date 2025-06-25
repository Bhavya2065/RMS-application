import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rms_application/feedback_page.dart';
import 'package:rms_application/help_support_page.dart';
import 'package:rms_application/order_page.dart';
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
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                color: Colors.white,
                border: Border.all(color: Colors.green, width: 1),
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
                  // User Name and Email
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, authSnapshot) {
                      if (authSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (!authSnapshot.hasData || authSnapshot.data == null) {
                        print("No user signed in");
                        return const Column(
                          children: [
                            Text(
                              'Guest',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'guest@example.com',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      }
                      final user = authSnapshot.data!;
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, docSnapshot) {
                          print(
                              "Firestore Snapshot: ${docSnapshot.connectionState}, Data: ${docSnapshot.data?.data()}");
                          print("Auth Email: ${user.email}");
                          if (docSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (docSnapshot.hasError) {
                            print("Firestore Error: ${docSnapshot.error}");
                            return const Column(
                              children: [
                                Text(
                                  'Error loading username',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Error loading email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          }
                          if (docSnapshot.hasData && docSnapshot.data!.exists) {
                            final data = docSnapshot.data!.data()
                                as Map<String, dynamic>?;
                            final username = data?['username'] as String? ??
                                'Anonymous User';
                            return Column(
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  user.email ?? 'No email set',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Text(
                                'Guest',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.email ?? 'guest@example.com',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            selectedIndex: widget.selectedIndex,
                            // Order History tab
                            onTabChange: (int index) {
                              setState(() {
                              });
                            },
                          ),
                        ),
                      );
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
                    },
                  ),
                  buildProfileOption(
                    icon: Icons.logout,
                    title: 'FeedBack',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
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
          color: Colors.white,
          border: Border.all(color: Colors.green, width: 1),
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
