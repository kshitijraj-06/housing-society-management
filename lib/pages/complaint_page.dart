import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';


class ComplaintDetailPage extends StatefulWidget {
  final String complaint;
  final String description;
  // final String imageUrl;

  const ComplaintDetailPage({
    Key? key,
    required this.complaint,
    required this.description,
    // required this.imageUrl,
  }) : super(key: key);



  @override
  _ComplaintDetailPageState createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  String getCurrentUserUid() {
    User? user = _auth.currentUser;
    String uid = user?.uid ?? '';
    return uid;
  }

  Future<bool> isAdminOrCM() async {
    try {
      User? user = _auth.currentUser;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      return userSnapshot['role'] == 'sc' || userSnapshot['role'] == 'cm';
    } catch (error) {
      print('Error checking admin/CM role: $error');
      return false;
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: LoadingFlipping.square(
        borderColor: Colors.grey,
        borderSize: 3.0,
        size: 30.0,
        backgroundColor: Colors.black,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isAdminOrCM(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError || !(snapshot.data as bool)) {
          return const Scaffold(
            body: Center(
              child: Text('Unauthorized access.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top :45 ,left: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    widget.complaint,
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                        letterSpacing: .5,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6.5),
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Text(
                    widget.description,
                    style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                          letterSpacing: 0,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                FutureBuilder(
                  future: _getUserName(getCurrentUserUid()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...');
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Raised by: ${snapshot.data}',
                          style: GoogleFonts.abel(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ));
                  },
                ),
                const SizedBox(
                  height: 28,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsResolved(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(5200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0)),
                      backgroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.thumb_up,
                    color: Colors.white,),
                    label: const Text('Mark as Resolved',
                    style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Text('Comments:',
                      style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('comments_Helpdesk')
                        .doc(widget.complaint)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
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

                      List<DocumentSnapshot> comments = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(comments[index]);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0 ,right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addComment,
                        icon: const Icon(Icons.send),
                        label: const Text('Add Comment'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            fixedSize: Size(170, 20),
                          foregroundColor: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _markAsResolved(BuildContext context) async {
    try {
      // Update the 'status' field to 'resolved' in the Firestore database
      await FirebaseFirestore.instance
          .collection('complaints')
          .where('complaint', isEqualTo: widget.complaint)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'status': 'resolved'});
        });
      });

      // Navigate back with a result indicating success
      Navigator.pop(context, true);
    } catch (error) {
      // Handle error
      print('Error marking complaint as resolved: $error');
      // You can show an error message to the user if needed
    }
  }

  Future<void> _addComment() async {
    try {
      String currentUserUid = getCurrentUserUid();

      // Add comment to the 'comments' subcollection of the complaint document
      await FirebaseFirestore.instance
          .collection('comments_Helpdesk')
          .doc(widget.complaint)
          .collection('comments')
          .add({
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUserUid,
      });

      // Clear the comment text field after adding
      _commentController.clear();
    } catch (error) {
      // Handle error
      print('Error adding comment: $error');
      // You can show an error message to the user if needed
    }
  }

  // Future<List<String>> _getComplaintPhotos() async {
  //   try {
  //     // Fetch complaint document from Firestore
  //     DocumentSnapshot complaintSnapshot = await FirebaseFirestore.instance
  //         .collection('complaints')
  //         .doc(widget.complaint)
  //
  //         .get();
  //
  //     // Check if the complaint document exists and contains the imageUrl field
  //     Map<String, dynamic>? data = complaintSnapshot.data() as Map<String, dynamic>?;
  //     if (data != null) {
  //       List<dynamic>? imageUrlList = data['imageUrl'] as List<dynamic>?;
  //
  //       if (imageUrlList != null) {
  //         // Convert imageUrlList to a list of strings
  //         List<String> imageUrlStrings = imageUrlList.cast<String>().toList();
  //         return imageUrlStrings;
  //       } else {
  //         print('No imageUrl found in the document');
  //         return [];
  //       }
  //     } else {
  //       print('Complaint document does not exist or is empty');
  //       return [];
  //     }
  //   } catch (error) {
  //     print('Error getting complaint photos: $error');
  //     return [];
  //   }
  // }




  Widget _buildCommentItem(DocumentSnapshot comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(comment['comment']),
        subtitle: FutureBuilder(
          future: _getUserName(comment['userId']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Text('By: ${snapshot.data}');
          },
        ),
      ),
    );
  }

  Future<String> _getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userSnapshot['name'];
    } catch (error) {
      print('Error getting user name: $error');
      return 'Unknown User';
    }
  }
}

