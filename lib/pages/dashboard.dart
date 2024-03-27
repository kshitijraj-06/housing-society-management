import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:spv/pages/add_delivery.dart';
import 'package:spv/pages/add_guests.dart';
import 'package:spv/pages/notice.dart';
import 'package:spv/pages/service.dart';
import 'package:spv/pages/social.dart';
import 'package:spv/pages/society_payment.dart';
import 'add_cab.dart';
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
    Service(),
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 35, left: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 20),
                        EaseInAnimation(
                          duration: Duration(seconds: 1),
                          child: Center(
                            child: Text(
                              'Spring Valley Phase - 1',
                              style: GoogleFonts.abel(
                                textStyle: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(user: getCurrentUser())),
                            );
                          },
                          child: CircleAvatar(
                            radius: 23,
                            backgroundImage: NetworkImage(
                              'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EaseInAnimation(
                      duration: Duration(seconds: 1),
                      child: Text(
                        'Pre - Approve Visitors',
                        style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EaseInAnimation(
                      duration: Duration(seconds: 1),
                      child: Text(
                        'Add Visitors Details for Quick Entries.',
                        style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          13), // Add spacing between the text and the card items
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
                            Colors.black,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddGuests(
                                          user: getCurrentUser(),
                                        )),
                              );
                            },
                          ),
                          _buildClickableCard('Add Delivery',
                              Icons.local_shipping, Colors.green, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddDelivery(
                                        user: getCurrentUser(),
                                      )),
                            );
                          }),
                          _buildClickableCard(
                              'Add Cab', Icons.directions_car, Colors.red, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCab(
                                        user: getCurrentUser(),
                                      )),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EaseInAnimation(
                      duration: Duration(seconds: 1),
                      child: Text(
                        'Community',
                        style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EaseInAnimation(
                      duration: Duration(seconds: 1),
                      child: Text(
                        'Everything for Spring Valley Phase - I',
                        style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    alignment: AlignmentDirectional.topStart,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: EaseInAnimation(
                      duration: Duration(seconds: 1),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return _buildVerticalListItem(
                              context, index); // Pass context
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        iconSize: 17,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        elevation: 0,
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
      'https://th.bing.com/th/id/OIG3.fuZsMt4l_foOATKohnfn?w=1024&h=1024&rs=1&pid=ImgDetMain',
      'https://img.freepik.com/premium-vector/3d-realistic-megaphone-white-background-concept-join-us-job-vacancy-announcement-modern-3d-cartoon-style-design-3d-vector-illustration_145666-1533.jpg?w=2000',
      'https://img.freepik.com/free-vector/bill-receipt-credit-card-3d-illustration-cartoon-drawing-paper-sheet-with-dollar-symbol-credit-card-3d-style-white-background-business-payment-finances-transaction-concept_778687-705.jpg',
      'https://img.freepik.com/premium-vector/calendar-reminder-date-spiral-icon-red-circle-style-simple-calendar-mark-date-holiday-important-day-concepts-vector-illustration-flat-style_165488-4093.jpg',
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
          case 'Society Payment':
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SocietyPayment()));
            break;
          case 'Book Amenities':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Will be added soon !! '),
              ),
            );
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
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptions[index % descriptions.length],
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.4,
                      ),
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
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: 110,
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.abel(
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
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
