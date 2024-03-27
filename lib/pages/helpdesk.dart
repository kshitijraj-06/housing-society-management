import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spv/pages/addcomplaint.dart';
import 'complaint_page.dart';

class HelpDeskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: EdgeInsets.only(top :45 ,left: 7),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 10,),
                EaseInAnimation(
                  duration : Duration(seconds: 1),
                  child: Text(
                    'HelpDesk',
                    style: GoogleFonts.abel(
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 140),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddComplaintPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
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

                List<DocumentSnapshot> complaints = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    return _buildComplaintCard(context, complaints[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, DocumentSnapshot complaint) {
    String status = complaint['status'] ?? 'unresolved';

    String imagePath = '';

    if (status == 'resolved') {
      imagePath = 'assets/images/RESOLVED.gif';
    } else {
      imagePath = 'assets/images/NEW.gif';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: EaseInAnimation(
        child: Card(
          elevation: 3,
          surfaceTintColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            title: Text(
              complaint['complaint'],
              style: GoogleFonts.abel(
                textStyle: const TextStyle(
                  letterSpacing: .5,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  complaint['description'],
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Raised by: ${complaint['name']}',
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Block: ${complaint['block']}',
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Flat Number: ${complaint['flatNumber']}',
                  style: GoogleFonts.abel(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComplaintDetailPage(
                    complaint: complaint['complaint'],
                    description: complaint['description'],
                    // imageUrl: complaint['imageUrl'],
                  ),
                ),
              );
            },
            trailing: Image.asset(
              imagePath,
              alignment: Alignment.topRight,
            ),
          ),
        ),
      ),
    );
  }
}


