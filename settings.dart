import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rms_application/main.dart';
import 'package:rms_application/sign_in.dart';
import 'package:rms_application/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(
              thickness: 2,
            ), // Divider after Notifications

            // Language Selection Section
            _buildSectionHeader('Language'),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: _languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Choose Language',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Divider(
              thickness: 2,
            ), // Divider after Language Selection

            // Theme Selection Section
            _buildSectionHeader('Theme'),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
              },
            ),
            Divider(
              thickness: 2,
            ), // Divider after Theme Selection

            // Logout Section
            _buildSectionHeader('Account'),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
            Divider(
              thickness: 2,
            ), // Divider after Logout

            // Delete Account Section
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Account', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Show a confirmation dialog before deleting the account
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                User? user = _auth.currentUser;

                if (user != null) {
                  String uid = user.uid;

                  try {
                    // Delete user data from Firestore
                    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

                    // Delete all user's orders
                    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: uid)
                        .get();

                    for (var doc in orderSnapshot.docs) {
                      await doc.reference.delete();
                    }

                    // Delete user from Firebase Authentication
                    await user.delete();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } catch (e) {
                    // Handle error (e.g., requires recent login)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting account: $e')),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}