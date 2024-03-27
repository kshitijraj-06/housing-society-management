import 'dart:io';
import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddGuests extends StatefulWidget {
  const AddGuests({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _AddGuestsState createState() => _AddGuestsState();
}

class _AddGuestsState extends State<AddGuests> {
  TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  String? selected_value;
  String? selected_travel;


  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return {};
  }

  Future<void> _camImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Future<void> _addimage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String imageUrl = '';

      if (_image != null) {
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('guestsimages/${DateTime.now()}.png');
        await storageReference.putFile(_image!);
        imageUrl = await storageReference.getDownloadURL();
      }

      final userData = await _fetchUserData(user.uid);

      final guest = {
        'userId': user.uid,
        'type' : selected_value,
        'travel' : selected_travel,
        'userName': userData['name'] as String? ?? '',
        'text': _descriptionController.text,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now(),
        'block': userData['block'] as String? ?? '',
        'flatNumber': userData['flatNumber'] as String? ?? '',
      };
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Record added Successfully.'),
        backgroundColor: Colors.green,
      ));

      await FirebaseFirestore.instance.collection('guests').add(guest);
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 65),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: EaseInAnimation(
                    duration: Duration(seconds: 1),
                    child: Text(
                      "Add Guests!",
                      style: GoogleFonts.abel(
                          textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                ),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.add,
                        size: 30,
                      )),
                ),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: IconButton(
                      onPressed: _camImage,
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        size: 30,
                      )),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(
                "Add your Guests/Visitors before hand so for faster approval.",
                style: GoogleFonts.abel(
                    textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButtonFormField<String>(
                hint: Text('Select Guest Type'),
                value: selected_value,
                items: <String>[
                  'Relative',
                  'Official Work',
                  'Friends',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selected_value = newValue!;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Guest Type',
                    helperText: 'Choose the type of guests for approval.'),
              ),
            ),
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButtonFormField<String>(
                hint: Text('Mode of Transport'),
                value: selected_travel,
                items: <String>[
                  'Car',
                  'Bike/Scooty',
                  'Cab',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selected_travel = newValue!;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mode of Transport',
                    helperText: 'Choose the mode of Transport of the guests'),
              ),
            ),
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Any Description',
                    helperText: 'Enter any description or instructions .'),
              ),
            ),
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _addimage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(5200, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0)),
                  backgroundColor: Colors.black,
                ),
                icon: const Icon(Icons.send),
                label: const Text('Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
