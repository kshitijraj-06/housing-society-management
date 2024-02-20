import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class PostCreationPage extends StatefulWidget {
  @override
  _PostCreationPageState createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final TextEditingController _postController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return {};
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _createPost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String imageUrl = '';

      // Upload image to Firebase Storage if available
      if (_image != null) {
        final storageReference =
        FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
        await storageReference.putFile(_image!);
        imageUrl = await storageReference.getDownloadURL();
      }

      final userData = await _fetchUserData(user.uid);

      final post = {
        'userId': user.uid,
        'userName': userData['name'] as String? ?? '',
        'text': _postController.text,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now(),
        'block': userData['block'] as String? ?? '',
        'flatNumber': userData['flatNumber'] as String? ?? '',
      };

      await FirebaseFirestore.instance.collection('posts').add(post);

      _postController.clear();
      Navigator.pop(context); // Close the post creation page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _createPost(context),
            child: Text('Share'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _postController,
              maxLines: 4,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Write your caption...',
                border: InputBorder.none,
              ),
            ),
          ),
          _image != null
              ? Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(_image!),
                fit: BoxFit.cover,
              ),
            ),
          )
              : Container(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(5200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.0)),
                backgroundColor: Colors.black,
              ),
              icon: const Icon(Icons.photo),
              label: const Text('Add Photo'),
            ),
          ),
        ],
      ),
    );
  }
}