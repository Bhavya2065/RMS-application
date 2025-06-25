import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rms_application/home_page.dart';

class verifyEmailScreen extends StatefulWidget {
  @override
  _verifyEmailScreenState createState() => _verifyEmailScreenState();
}

class _verifyEmailScreenState extends State<verifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEmailVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload();
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FoodMenuScreen(),
          ));
    }
  }

  Future<void> _resendEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Verification email resent!!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send verification email: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/rms.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFEAF1DF),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'A Verification email link has been sent to your email address.\nPlease check your Email!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _checkEmailVerification,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'I have Verifiied',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                        ),
                        SizedBox(height: 10),
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.green)
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _resendEmailVerification,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Resend Verification Email',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      )),
    );
  }
}
