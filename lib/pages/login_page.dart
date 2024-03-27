import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (FirebaseAuth.instance.currentUser != null) {
        print("User logged in: ${FirebaseAuth.instance.currentUser!.uid}");

        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print("Error: Failed to log in");
      }
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
             SizedBox(height: MediaQuery.of(context).size.height /2000),
            Image.network('https://firebasestorage.googleapis.com/v0/b/spring-valley-e2a8f.appspot.com/o/items%2FCream%20And%20Purple%20Illustrative%20Travel%20Agency%20Logo.png?alt=media&token=6997d919-6c58-4c6b-9f6d-da8ca435275e'),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Hello,',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          fontSize: 21.0,
                          color: Colors.grey,
                        ),
                      )
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Sign In Now',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          fontSize: 27.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600
                        ),
                      )
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email Address',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                        )
                      )
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter Email Address',
                  fillColor: Colors.grey,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Password',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18
                      )
                  )
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter Password',
                  fillColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 25.0),

            // Continue button
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    _handleLogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(500, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                        )
                    )
                  ),
                )),
            SizedBox(height: MediaQuery.of(context).size.height/50),
            // App developer credit
            const Text('Kshitij Ranjan'),
          ],
        ),
      ),
    );
  }
}
