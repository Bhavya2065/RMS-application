import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Feedbacks", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedbacks')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading feedback"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          }

          final feedbackDocs = snapshot.data!.docs;

          if (feedbackDocs.isEmpty) {
            return Center(child: Text("No feedback submitted yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final data = feedbackDocs[index].data() as Map<String, dynamic>;

              final username = data['username'] ?? 'Unknown';
              final email = data['email'] ?? 'N/A';
              final message = data['message'] ?? 'No message';

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.green),
                  title: Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: TextStyle(color: Colors.black87)),
                      SizedBox(height: 6),
                      Text(message, style: TextStyle(color: Colors.black54)),
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
