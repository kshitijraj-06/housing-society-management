import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../notice/notice creation.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                'Notice Board',
                style: GoogleFonts.abel(
                  textStyle: const TextStyle(
                    letterSpacing: .5,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded( // Use Expanded instead of Flexible
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notices')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot> notices = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      return _buildnoticesCard(context, notices[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );

  }

  Widget _buildFloatingActionButton(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // Check if the user is authenticated
    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // Check if the user has the 'sc' role
          if (snapshot.data?['role'] == 'sc') {
            return FloatingActionButton(
              onPressed: () {
                // Navigate to the notice creation page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoticeCreationPage(),
                  ),
                );
              },
              child: Icon(Icons.add),
            );
          } else {
            return Container(); // Return an empty container if the user doesn't have the 'sc' role
          }
        },
      );
    } else {
      return Container(); // Return an empty container if the user is not authenticated
    }
  }

  Widget _buildnoticesCard(BuildContext context, DocumentSnapshot notices) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: ListTile(
          title: Column(
            children: [
              Image.asset(
                'assets/images/ANC.png', // Replace with your asset image path
                width: 170, // Adjust the width as needed
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      notices['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                notices['content'],
                style: GoogleFonts.abel(
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Added by: Admin',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                _formatTimestamp(notices['timestamp']),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                _formatTimestamptime(notices['timestamp']),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const SizedBox(width: 250),
                  IconButton(
                    color: Colors.black,
                    icon: const Icon(Icons.thumb_up),
                    onPressed: () {
                      _updateLikes(notices
                          .id);
                    },
                  ),

                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    notices['likes'].toString(),
                    style: GoogleFonts.abel(),
                  ),

                ],
              ),
            ],
          ),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ComplaintDetailPage(
            //       complaint: complaint['complaint'],
            //       description: complaint['description'],
            //     ),
            //   ),
            // );
          },
        ),
      ),
    );
  }

  Future<void> _updateLikes(String noticeId) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        // Get the current user's UID
        String userId = user.uid;

        // Retrieve the user's name from the 'users' collection
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        String userName = userSnapshot['name'] ?? 'Unknown User';

        // Update the 'likes' field in the Firestore database for the specific notice
        await FirebaseFirestore.instance
            .collection('notices')
            .doc(noticeId)
            .update({
          'likes': FieldValue.increment(1),
          'reactions': FieldValue.arrayUnion([
            {'userId': userId, 'userName': userName, 'reactionType': 'like'}
          ]),
        });
      } else {
        // Handle the case where the user is not authenticated
        print('User not authenticated');
      }
    } catch (error) {
      print('Error updating likes: $error');
      // Handle error, e.g., show a message to the user
    }
  }

  Future<void> _updateDislikes(String noticeId) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        // Get the current user's UID
        String userId = user.uid;

        // Retrieve the user's name from the 'users' collection
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        String userName = userSnapshot['name'] ?? 'Unknown User';

        // Update the 'likes' field in the Firestore database for the specific notice
        await FirebaseFirestore.instance
            .collection('notices')
            .doc(noticeId)
            .update({
          'dislikes': FieldValue.increment(1),
          'reactions': FieldValue.arrayUnion([
            {'userId': userId, 'userName': userName, 'reactionType': 'dislikes'}
          ]),
        });
      } else {
        // Handle the case where the user is not authenticated
        print('User not authenticated');
      }
    } catch (error) {
      print('Error updating likes: $error');
      // Handle error, e.g., show a message to the user
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Use your desired date format, e.g., 'yyyy-MM-dd HH:mm:ss'
    final formattedDate = DateFormat.yMMMd().format(timestamp.toDate());
    return formattedDate;
  }

  String _formatTimestamptime(Timestamp timestamp) {
    // Use your desired date format, e.g., 'yyyy-MM-dd HH:mm:ss'
    final formattedDate = DateFormat.jms().format(timestamp.toDate());
    return formattedDate;
  }
}
