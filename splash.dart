import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rms_application/home_page.dart';
import 'package:rms_application/sign_up.dart';
import 'package:rms_application/admin_home_page.dart';

import 'main.dart'; // Added missing import

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      body: Center(
        child: TweenAnimationBuilder(
          duration: Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/rms_logo1.png',
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String> _getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = doc.data()?['role'] ?? 'user'; // Simplified logic
    if (doc.exists) print('User $uid role: $role'); // Debug print if doc exists
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseAuth.instance.currentUser != null
          ? _getUserRole(FirebaseAuth.instance.currentUser!.uid)
          : Future.value('user'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }
        final role = snapshot.data ?? 'user';
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          return HomePage();
        } else if (!user.emailVerified) {
          return SignUpPage();
        } else if (role == 'admin') {
          return AdminHomePage();
        } else {
          return FoodMenuScreen();
        }
      },
    );
  }
}