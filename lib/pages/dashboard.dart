import 'dart:math';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_bottom_bar/diamond_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:readmore/readmore.dart';
import 'package:spv/pages/notice.dart';
import 'package:spv/pages/social.dart';
import 'package:spv/pages/society_payment.dart';
import 'package:spv/widgets/card.dart';
import 'profile_page.dart';
import 'package:animated_flutter_widgets/animated_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage(
      {super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  int _currentIndex = 2;

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;


    var labelStyle = GoogleFonts.montserrat(
        textStyle: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black));

    const Color background = Colors.black;
    const Color fill = Colors.white;
    final List<Color> gradient = [
      background,
      background,
      fill,
      fill,
    ];
    const double fillPercent = 70.23; // 73.23% neeche se white rhega screen
    const double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingIndicator()
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          height: 180,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.green,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 20, left: 14),
                                  child: EaseInAnimation(
                                    duration: Duration(seconds: 1),
                                    child: Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'Spring Valley Phase - 1',
                                        style: GoogleFonts.montserrat(
                                          textStyle: const TextStyle(
                                              fontSize: 25, color: Colors.white
                                              // fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: Row(
                                    children: [
                                      EaseInAnimation(
                                        duration: Duration(seconds: 1),
                                        child: Text(
                                          'One Step for all your needs',
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: EaseInAnimation(
                                    duration: Duration(seconds: 1),
                                    child: Text(
                                      'Spring Valley Phase - 1 , Lalpur, Ranchi, Jharkhand - 834001',
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Cards(
                            title: 'HelpDesk',
                            url:
                                'https://firebasestorage.googleapis.com/v0/b/dashdrop-1d768.appspot.com/o/items%2FCream%20And%20Purple%20Illustrative%20Travel%20Agency%20Logo%20(1).png?alt=media&token=b6fea3e8-bc39-4c45-99c4-60d99f8ff8cb',
                            onTapp: () {
                              Navigator.pushNamed(context, '/helpdesk');
                            },
                          ),
                          Cards(
                              title: 'Notices',
                              url:
                                  'https://firebasestorage.googleapis.com/v0/b/dashdrop-1d768.appspot.com/o/items%2FCream%20And%20Purple%20Illustrative%20Travel%20Agency%20Logo%20(1).png?alt=media&token=b6fea3e8-bc39-4c45-99c4-60d99f8ff8cb',
                              onTapp: () {
                                Navigator.pushNamed(context, '/notice_board');
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          Cards(
                              title: 'Payments',
                              url:
                                  'https://firebasestorage.googleapis.com/v0/b/dashdrop-1d768.appspot.com/o/items%2FCream%20And%20Purple%20Illustrative%20Travel%20Agency%20Logo%20(1).png?alt=media&token=b6fea3e8-bc39-4c45-99c4-60d99f8ff8cb',
                              onTapp: () {
                                Navigator.pushNamed(context, '/payments');
                              }),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Notices',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: width,
                          child: Card(
                              color: Colors.yellow.shade400,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ReadMoreText(
                                    'Flutter is Google’s mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase.',
                                    trimMode: TrimMode.Line,
                                    trimLines: 3,
                                    colorClickableText: Colors.green,
                                    trimCollapsedText: 'Read More',
                                    trimExpandedText: 'Show Less',
                                    style: labelStyle,
                                  ))),
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
                            'Upcoming Events',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EventCalendar(
                          calendarType: CalendarType.GREGORIAN,
                          calendarLanguage: 'en',
                          calendarOptions: CalendarOptions(
                            viewType: ViewType.DAILY,
                            toggleViewType: true,
                            headerMonthBackColor: Colors.green,
                          ),
                          showLoadingForEvent: true,
                          dayOptions: DayOptions(
                            selectedBackgroundColor: Colors.black,
                            selectedTextColor: Colors.white,
                            disableFadeEffect: true,
                          ),
                          eventOptions: EventOptions(
                              emptyText: 'No Event',
                              emptyIcon: Icons.error,
                              emptyTextColor: Colors.black),
                          events: [
                            Event(
                              child: Text('Holi'),
                              dateTime: CalendarDateTime(
                                  year: 2024,
                                  month: 6,
                                  day: 4,
                                  calendarType: CalendarType.GREGORIAN),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void onPressed(index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/notice_board');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/visitors');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/dashboard');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/social');
      } else if (index == 4) {
        Navigator.pushNamed(context, '/pp');
      }
    });
  }

  getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }
}
