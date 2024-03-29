import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class AddComplaintPage extends StatefulWidget {
  @override
  _AddComplaintPageState createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  TextEditingController _complaintController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _complaintController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Form(
            key: _formKey, // Set form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 12),
                  child: Row(
                    children: [
                      EaseInAnimation(
                        duration: Duration(seconds: 1),
                        child: Text('Add Complaint',
                            style: GoogleFonts.abel(
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: EaseInAnimation(
                    duration: Duration(seconds: 1),
                    child: Text(
                      'Complaint : ',
                      style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                          letterSpacing: .5,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: TextFormField(
                    controller: _complaintController,
                    decoration: InputDecoration(
                      labelText: "Enter Complaint",
                      fillColor: Colors.white,
                      focusColor: Colors.green,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        // Check if complaint is empty
                        return "Complaint cannot be empty";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: EaseInAnimation(
                    duration: Duration(seconds: 1),
                    child: Text(
                      'Description : ',
                      style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                          letterSpacing: .5,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Enter Description",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        // Check if complaint is empty
                        return "Description cannot be empty";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                SizedBox(height: 50),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String complaint = _complaintController.text;
                          String description = _descriptionController.text;

                          User? user = FirebaseAuth.instance.currentUser;
                          String? userId = user?.uid;

                          if (userId != null) {
                            // Retrieve user information from Firestore
                            DocumentSnapshot userSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .get();

                            if (userSnapshot.exists) {
                              String name = userSnapshot['name'];
                              String block = userSnapshot['block'];
                              String flatNumber = userSnapshot['flatNumber'];

                              // Add the complaint to Firestore with user information
                              try {
                                await FirebaseFirestore.instance
                                    .collection('complaints')
                                    .add({
                                  'complaint': complaint,
                                  'description': description,
                                  'name': name,
                                  'block': block,
                                  'flatNumber': flatNumber,
                                  'status':
                                      'unresolved', // Set default status to 'unresolved'
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'userId': userId,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Complaint submitted successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _complaintController.clear();
                                _descriptionController.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to submit complaint. Please try again later.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'User information not found. Please try again later.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Text('Submit Complaint',
                      style: GoogleFonts.abel(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700
                        )
                      ),),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black), // Change background color
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Change text color
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            // You can adjust the border radius as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
