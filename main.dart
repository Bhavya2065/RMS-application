import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rms_application/mobile_auth.dart';
import 'package:rms_application/sign_in.dart';
import 'package:rms_application/splash.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1DF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  "My",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF58A05A),
                  ),
                ),
                Text(
                  "Restaurant",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF58A05A),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Text(
              "Welcome",
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            SizedBox(height: 20),

            // Sign In button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF58A05A),
                minimumSize: Size(300, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign in",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            SizedBox(height: 15),

            // Sign Up button (Outlined)
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MobileAuth()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF58A05A), width: 2),
                minimumSize: Size(300, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign up",
                style: TextStyle(
                  color: Color(0xFF58A05A),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
