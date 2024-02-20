import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Service extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 65, left: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(
                  width: 272,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 29),
            child: Row(
              children: [
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: Text(
                    'Service Desk',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 300,),
          Center(
              child: Text('Feature will be added soon!!'),
            ),
        ],
      ),
    );
  }
}
