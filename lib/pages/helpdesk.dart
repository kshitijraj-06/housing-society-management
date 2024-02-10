import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spv/pages/addcomplaint.dart';
import 'complaint_page.dart';

class HelpDeskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 65, left: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(
                  width: 272,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddComplaintPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.add))
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 29),
            child: Row(
              children: [
                Text(
                  'HelpDesk',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 190),
                Icon(Icons.filter_list_outlined),
              ],
            ),
          ),

          // Fetch data from Firestore and display in card items
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

    // Define network image URLs for different statuses
    String imagePath = '';
    double imageSize = 140.0;
    if (status == 'resolved') {
      imagePath = 'assets/images/RESOLVED.png';
    } else {
      imagePath = 'assets/images/NEW.png';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Text(
            complaint['complaint'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                complaint['description'],
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 22),
              Text(
                'Raised by: ${complaint['name']}',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                'Block: ${complaint['block']}',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Flat Number: ${complaint['flatNumber']}',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComplaintDetailPage(
                  complaint: complaint['complaint'],
                  description: complaint['description'],
                  imageUrl: complaint['imageUrl'],
                ),
              ),
            );
          },
          trailing: Image.asset(
            imagePath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}


