import 'dart:io';
import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddDelivery extends StatefulWidget {
  const AddDelivery({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _AddDeliveryState createState() => _AddDeliveryState();
}

class _AddDeliveryState extends State<AddDelivery> {
  TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  String? selected_partner;
  String? selected_sod;


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



  Future<void> _adddelivery() async {
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

      final delivery = {
        'userId': user.uid,
        'partner' : selected_partner,
        'size' : selected_sod,
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

      await FirebaseFirestore.instance.collection('delivery').add(delivery);
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
                      "Add Delivery Details!",
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
                "Add delivery details before hand for faster approval.",
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
                hint: Text('Select Delivery Company'),
                value: selected_partner,
                items: <String>[
                  'Amazon',
                  'Flipkart',
                  'Delhivery',
                  'BlueDart',
                  'Others'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selected_partner = newValue!;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Delivery Partner',
                    helperText: 'Choose the Delivery Partner.'),
              ),
            ),
          ),
          EaseInAnimation(
            duration: Duration(seconds: 1),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButtonFormField<String>(
                hint: Text('Select Size of Delivery'),
                value: selected_sod,
                items: <String>[
                  'Small',
                  'Big',
                  'Very Big',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selected_sod = newValue!;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Size of Delivery',
                    helperText: 'Choose Size of the your Parcel.'),
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
                onPressed: _adddelivery,
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
