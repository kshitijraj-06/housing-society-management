import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:spv/pages/helpdesk.dart';
import 'package:spv/pages/notice.dart';
import 'package:spv/pages/payments.dart';
import 'package:spv/pages/profile_page.dart';
import 'package:spv/pages/social.dart';
import 'package:spv/pages/society_payment.dart';
import 'package:spv/pages/visitors.dart';
import 'firebase_options.dart';
import 'pages/dashboard.dart';
import 'pages/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PDFView;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);


  checkIfLogin() async{
    auth.authStateChanges().listen((User? user) {
      if(user!= null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkIfLogin();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Society Management App',
      theme: ThemeData(),
      home:
          isLogin? DashboardPage() : LoginPage(),
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/helpdesk' : (context) => HelpDeskPage(),
        '/notice_board' : (context) => NoticePage(),
        '/maintenance' : (context) => SocietyPayment(),
        '/social' : (context) => SocialPage(),
        '/pp' : (context) => ProfilePage(user: getCurrentUser()),
        '/visitors' : (context) => Visitors(),
        '/payments' : (context) => Payments(),
      },
    );
  }
}
