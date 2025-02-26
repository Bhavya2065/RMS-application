import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rms_application/main.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF), // Background color
      body: Center(
        child: TweenAnimationBuilder(
          duration: Duration(seconds: 4), // Duration of the animation
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
