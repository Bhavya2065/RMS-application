import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rms_application/home_page.dart';
import 'package:rms_application/sign_in.dart';
import 'package:rms_application/sign_up.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthWrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      body: Center(
        child: TweenAnimationBuilder(
          duration: Duration(seconds: 2), // Duration of the animation
          tween: Tween(begin: 0.0, end: 1.0), // Scale animation
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/rms_logo1.png', // Replace with your logo path
            width: 300, // Set appropriate width
            height: 300, // Set appropriate height
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null){
      return SignInPage();
    } else if(!user.emailVerified){
      return SignUpPage();
    } else{
      return FoodMenuScreen();
    }
  }
}
