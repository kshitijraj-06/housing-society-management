import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:spv/pages/dashboard.dart';
import 'package:spv/social/group_chat.dart';
import '../social/post_creation_page.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String block;
  final String flatNumber;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.block,
    required this.flatNumber,
  });
}

class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });
}

class SocialPost {
  String postId;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final String block;
  final String flatNumber;
  int likes;
  List<Comment> comments;

  SocialPost({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.block,
    required this.flatNumber,
    this.likes = 0,
    this.comments = const [],
  });
}

class SocialPage extends StatefulWidget {
  @override
  _SocialPageState createState() => _SocialPageState();
}

Widget _buildLoadingIndicator() {
  return Center(
    child: LoadingFlipping.circle(
      borderColor: Colors.cyan,
      borderSize: 3.0,
      size: 30.0,
      backgroundColor: Colors.cyanAccent,
      duration: Duration(milliseconds: 500),
    ),
  );
}

class _SocialPageState extends State<SocialPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 45, left: 12),
            child: Row(
              children: <Widget>[
                Text(
                  'Spring Valley Phase - 1',
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      fontSize:24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 60),
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                      'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg'), // Replace with your Firebase image URL
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  _buildLoadingIndicator();

                }

                final posts = snapshot.data?.docs ?? [];

                // Sort posts by timestamp
                posts.sort((a, b) {
                  final timestampA = (a['timestamp'] as Timestamp).toDate();
                  final timestampB = (b['timestamp'] as Timestamp).toDate();
                  return timestampB.compareTo(timestampA);
                });

                return PostList(posts: posts);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}

Widget _buildBottomNavigationBar(BuildContext context) {
  String currentUserId = ''; // Initialize with an empty string
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    currentUserId = user.uid; // Assign the current user ID
  }
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.transparent,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    iconSize: 17,
    selectedFontSize: 12,
    unselectedFontSize: 10,
    elevation: 0,
    currentIndex: 1,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.horizontal_split_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.facebook),
        label: 'Social',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Chats',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'Add',
      ),
    ],
    onTap: (index) {
      // Handle bottom navigation bar clicks
      if (index == 0) {
        // Navigate to the post creation page when "Add" is clicked
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  DashboardPage()),
        );
      } else {
        if (index == 1) {
          // Navigate to the post creation page when "Add" is clicked
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SocialPage()),
          );
        } else {
          if (index == 3) {
            // Navigate to the post creation page when "Add" is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostCreationPage()),
            );
          } else {
            if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        currentUserId: currentUserId
                    )
                  ));
            }
          }
        }
      }
    },
  );
}



class PostList extends StatelessWidget {
  final List<DocumentSnapshot> posts;

  PostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final data = posts[index].data() as Map<String, dynamic>;

        final imageUrl = data['imageUrl'] ?? '';
        final userId = data['userId'] as String? ?? '';
        final text = data['text'] as String? ?? '';
        final timestamp =
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        final block = data['block'] as String? ?? '';
        final flatNumber = data['flatNumber'] as String? ?? '';

        final likes = data['likes'] as int? ?? 0;
        final commentsData = data['comments'] as List<dynamic>? ?? [];
        final comments = commentsData.map((commentData) {
          return Comment(
            userId: commentData['userId'] as String? ?? '',
            userName: commentData['userName'] as String? ?? '',
            text: commentData['text'] as String? ?? '',
            timestamp: (commentData['timestamp'] as Timestamp?)?.toDate() ??
                DateTime.now(),
          );
        }).toList();

        final post = SocialPost(
          postId: posts[index].id,
          userId: userId,
          userName: data['userName'] as String? ?? '',
          text: text,
          imageUrl: imageUrl,
          timestamp: timestamp,
          block: block,
          flatNumber: flatNumber,
          likes: likes,
          comments: comments,
        );

        return PostCard(post: post);
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final SocialPost post;

  PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  TextEditingController _commentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: Card(
        surfaceTintColor: Colors.green,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg'), // Add user avatar URL
              ),
              title: Text(
                widget.post.userName,
                style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '${widget.post.block} - ${widget.post.flatNumber}',
                    style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    )),
                  ),
                  const SizedBox(
                    width: 140,
                  ),
                  Text(
                    '${_formatTimestamp(widget.post.timestamp)}',
                    style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    )),
                  ),
                ],
              ),
            ),

            if (widget.post.imageUrl.isNotEmpty)
              FutureBuilder(
                future: _getImageDimensions(widget.post.imageUrl),
                builder: (context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Placeholder or loading indicator
                  }

                  final imageDimensions = snapshot.data ?? const Size(1, 1);

                  return AspectRatio(
                    aspectRatio: imageDimensions.aspectRatio,
                    child: Image.network(
                      widget.post.imageUrl,
                      fit: BoxFit.fill,
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      LikeButton(
                        onTap: _toggleLike,
                        likeCount: null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.mode_comment_outlined),
                        color: Colors.black,
                        onPressed: () {
                          _showCommentsDialog();
                        },
                      ),
                      const SizedBox(width: 4),


                      const SizedBox(width: 4),

                    ],
                  ),
                ],
              ),

            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text('${widget.post.likes} Likes',
              style: GoogleFonts.abel(
                textStyle : TextStyle(
                  fontSize: 12,
                )
              ),),

            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                widget.post.text,
                style: GoogleFonts.abel(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Add Comment Input Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.grey[200], // Set the background color
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(fontSize: 15),
                            border: InputBorder.none, // Remove the default border
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width:
                          10), // Add some spacing between text field and button
                  Material(
                    color:
                        Colors.transparent, // Match the parent container's color
                    borderRadius: BorderRadius.circular(25.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25.0),
                      onTap: () {
                        _addComment();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.send,
                            color: Colors.black), // Customize the icon color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTimestamp(comment.timestamp),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      // Show the date if the post is older than a day
      return DateFormat.yMd().format(timestamp);
    } else if (difference.inHours > 0) {
      // Show hours ago if the post is within the last day
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Show minutes ago if the post is within the last hour
      return '${difference.inMinutes}m ago';
    } else {
      // Show just now if the post is within the last minute
      return 'Just now';
    }
  }

  Future<bool> _toggleLike(bool isLiked) async {
    try {
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          widget.post.likes++;
        } else {
          widget.post.likes--;
        }
      });

      // Update likes in Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'likes': widget.post.likes,
      });

      return true; // Return true if the operation succeeds
    } catch (error) {
      print('Error toggling like: $error');
      // Revert UI changes if the update fails
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          widget.post.likes--;
        } else {
          widget.post.likes++;
        }
      });
      return false; // Return false if the operation fails
    }
  }


  void _showCommentsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 67,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text('Comments',
                    style: GoogleFonts.abel(
                        textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ))),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: widget.post.comments
                      .map((comment) => _buildCommentItem(comment))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _fetchUserData(user.uid);

      final newComment = Comment(
        userId: user.uid,
        userName: userData['name'] as String? ?? '',
        text: _commentController.text,
        timestamp: DateTime.now(),
      );

      setState(() {
        widget.post.comments.add(newComment);
        _commentController.clear();
      });

      // Update comments in Firestore
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': newComment.userId,
            'userName': newComment.userName,
            'text': newComment.text,
            'timestamp': newComment.timestamp,
          }
        ])
      });
    }
  }

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

  Future<Size> _getImageDimensions(String imageUrl) async {
    final image = await decodeImageFromList(
        (await http.get(Uri.parse(imageUrl))).bodyBytes);

    return Size(image.width.toDouble(), image.height.toDouble());
  }

}
