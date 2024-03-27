import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoticeCard {
  Widget _buildnoticesCard(BuildContext context, DocumentSnapshot notices) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Card(
        elevation: 3,
        surfaceTintColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: EaseInAnimation(
          duration: Duration(seconds: 1),
          child: ListTile(
            title: Column(
              children: [
                Text("NOTICE",
                  style: GoogleFonts.abel(
                      textStyle : TextStyle()
                  ),),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        notices['title'],
                        style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                            letterSpacing: .5,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 200),
                    IconButton(
                      color: Colors.black,
                      icon: const Icon(Icons.thumb_up_off_alt_outlined),
                      onPressed: () {
                        _updateLikes(notices
                            .id);
                      },
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