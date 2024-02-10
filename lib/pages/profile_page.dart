import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? role;
  String? block;
  String? flatNumber;
  String? name;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchAdditionalUserData();
  }

  void fetchAdditionalUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          role = documentSnapshot['role'];
          block = documentSnapshot['block'];
          flatNumber = documentSnapshot['flatNumber'];
          name = documentSnapshot['name'];
          phone = documentSnapshot['phone'];
        });
      } else {
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 65,),
                child: Row(
                  children: [
                    EaseInAnimation(
                      duration: Duration(seconds: 2),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      width: 272,
                    ),
                  ],
                ),
              ),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: const Padding(
                  padding: EdgeInsets.only(top: 20, left: 14),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Profile Page',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60,),
              FastOutSlowInAnimation(
                duration: const Duration(seconds: 3),
                scale: 0.5,
                child: Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(widget.user.photoURL ??
                        'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg'),
                  ),
                ),
              ),
              const SizedBox(height:60),
              EaseInAnimation(
                  duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Name : $name',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Flat Number : $flatNumber',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Block: $block',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Phone Number: $phone',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // Additional profile information sections
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Type: $role',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
