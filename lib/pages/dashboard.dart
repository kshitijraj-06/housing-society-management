import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:spv/pages/notice.dart';
import 'package:spv/pages/social.dart';
import 'helpdesk.dart';
import 'profile_page.dart';
import 'package:animated_flutter_widgets/animated_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;

  _onTap() {
    // this has changed
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            _children[_currentIndex])); // this has changed
  }

  final List<Widget> _children = [
    DashboardPage(),
    SocialPage(),
  ];

  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingIndicator() : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 65, left: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 35),
                  EaseInAnimation(
                    duration: Duration(seconds: 1),
                    child: Text(
                      'Spring Valley Phase - 1',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 35),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage(user: getCurrentUser())),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg',
                      ),
                    ),
                  ),


                ],
              ),
            ),

            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: Text(
                  'Pre - Approve Visitors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: Text(
                  'Add Visitors Details for Quick Entries.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 16), // Add spacing between the text and the card items
            SizedBox(
              height: 150, // Adjust the height as needed
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildClickableCard(
                      'Add Guests',
                      Icons.people,
                      Colors.blue,
                      () {
                        // Handle click for Add Guests
                        if (kDebugMode) {
                          print('Add Guests Clicked');
                        }
                      },
                    ),
                    _buildClickableCard(
                      'Add Delivery',
                      Icons.local_shipping,
                      Colors.green,
                      () {
                        // Handle click for Add Delivery
                        if (kDebugMode) {
                          print('Add Delivery Clicked');
                        }
                      },
                    ),
                    _buildClickableCard(
                      'Add Service',
                      Icons.build,
                      Colors.orange,
                      () {
                        // Handle click for Add Service
                        if (kDebugMode) {
                          print('Add Service Clicked');
                        }
                      },
                    ),
                    _buildClickableCard(
                      'Add Cab',
                      Icons.directions_car,
                      Colors.red,
                      () {
                        // Handle click for Add Cab
                        if (kDebugMode) {
                          print('Add Cab Clicked');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: Text(
                  'Everything about society management',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.only(bottom: 0),
              height: 450, // Set the height explicitly
              child: EaseInAnimation(
                duration: Duration(seconds: 1),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildVerticalListItem(context, index); // Pass context
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.home_repair_service),
            label: 'Service',
          ),
        ],
        onTap: (index) {
          // this has changed
          setState(() {
            _currentIndex = index;
          });
          _onTap();
        },
      ),
    );
  }

  Widget _buildVerticalListItem(BuildContext context, int index) {
    List<String> titles = [
      'HelpDesk',
      'Notice Board',
      'Society Payment',
      'Book Amenities',
    ];

    List<String> descriptions = [
      'Complaint & Suggestion',
      'Society Announcement',
      'Payment Details for the society',
      'Pre Book Society Amenities',
    ];

    List<String> imageUrls = [
      'https://cdn.vectorstock.com/i/preview-1x/09/51/portrait-confused-anime-boy-with-question-mark-vector-34070951.jpg',
      'https://img.freepik.com/premium-vector/3d-realistic-megaphone-white-background-concept-join-us-job-vacancy-announcement-modern-3d-cartoon-style-design-3d-vector-illustration_145666-1533.jpg?w=2000',
      'https://img.freepik.com/free-vector/bill-receipt-credit-card-3d-illustration-cartoon-drawing-paper-sheet-with-dollar-symbol-credit-card-3d-style-white-background-business-payment-finances-transaction-concept_778687-705.jpg',
      'https://previews.123rf.com/images/tovovan/tovovan2203/tovovan220300014/182790817-calendar-with-one-day-selected-3d-vector-illustration.jpg',
    ];

    double imageSize = 100.0 + (index % 3) * 1.0;

    return InkWell(
      onTap: () {
        switch (titles[index]) {
          case 'HelpDesk':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpDeskPage()),
            );
            break;
          // Add more cases for other titles and corresponding pages
          case 'Notice Board':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoticePage()),
            );
            break;
          // Add more cases as needed

          default:
            if (kDebugMode) {
              print('List Item $index Clicked');
            }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[index % titles.length],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptions[index % descriptions.length],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Image.network(
                imageUrls[index % imageUrls.length],
                width: imageSize,
                height: imageSize,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableCard(
      String title, IconData icon, Color color, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: 120, // Adjust the width as needed
            height: 120, // Adjust the height as needed
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: color),
                  const SizedBox(height: 8),
                  Text(title),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }
}
