import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NoticeCreationPage extends StatefulWidget {
  @override
  _NoticeCreationPageState createState() => _NoticeCreationPageState();
}

class _NoticeCreationPageState extends State<NoticeCreationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(
              top: 45,
              left: 16,
              right: 16,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0),
                child: Text(
                  'Add Announcement',
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      letterSpacing: .5,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter the title...',
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _contentController,
                      label: 'Content',
                      hint: 'Enter the content...',
                      maxLines: 5 ,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _createNotice(), // Corrected function call
                      child: Text('Create Annoucement'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        enableFeedback: true,
                      ),
                    ),

                  ],
                ),
              ),
            ])));
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  void _createNotice() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        String userName = userSnapshot['name'] ?? 'Unknown User';

        // Create a reference to the notices collection
        CollectionReference noticesCollection =
        FirebaseFirestore.instance.collection('notices');

        // Add a new document with a generated ID
        await noticesCollection.add({
          'title': _titleController.text,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'addedBy': userName,
          'likes': 0,
          'dislikes': 0,
        });

        // Notify user that the notice has been created
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice created successfully!'),
          ),
        );

        // Clear the text fields
        _titleController.clear();
        _contentController.clear();
      } else {
        print('User not authenticated');
      }
    } catch (error) {
      print('Error creating notice: $error');
      // Notify user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating notice. Please try again.'),
        ),
      );
    }
  }

}
