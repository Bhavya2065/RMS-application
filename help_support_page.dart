import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Help & Support'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'If you need help or have any questions, please contact us at:\n\n'
              '📧 myrestro@gmail.com\n\n'
              'We’ll get back to you as soon as possible.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
