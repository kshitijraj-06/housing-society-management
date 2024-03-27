import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:spv/pages/payment_updation.dart';
import 'package:spv/pages/profile_page.dart';
import 'invoice/invoices.dart';

class SocietyPayment extends StatefulWidget {
  @override
  _SocietyPaymentState createState() => _SocietyPaymentState();
}

class _SocietyPaymentState extends State<SocietyPayment> {
  List<Map<String, dynamic>>? _paymentData;
  bool _fetchingData = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await fetchData();
      setState(() {
        _paymentData = data;
        _fetchingData = false;
      });
    } on Exception catch (error) {
      setState(() {
        _fetchingData = false;
      });
      print('Error fetching data: $error');
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45, left: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 25),
                  ),
                  const SizedBox(width: 130),
                  IconButton(
                      icon: const Icon(
                        Icons.add,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SocietyMaintenanceUpdation()));
                      }),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_outlined,
                    ),
                    onPressed: _fetchingData
                        ? null
                        : _fetchData,
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(user: getCurrentUser())),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 29),
              child: Row(
                children: [
                  Text(
                    'Society Maintenance',
                    style: GoogleFonts.abel(
                        textStyle: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ), )
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),
            // Display loading indicator or error message while fetching data
            SingleChildScrollView(
              child: _fetchingData
                  ? Center(child: _buildLoadingIndicator())
                  : _paymentData?.isEmpty ?? true
                      ? const Center(child: Text('No payment data found'))
                      : _buildPaymentTable(_paymentData!),
            ),
            SizedBox(
              height: 30,
            ),
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => InvoiceGenerator(selectedMonth: selectedMonth)));
            //     },
            //     icon: Icon(Icons.file_download_outlined),
            //     label: Text('Download'),
            //     style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all<Color>(
            //           Colors.black), // Change background color
            //       foregroundColor: MaterialStateProperty.all<Color>(
            //           Colors.white), // Change text color
            //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(18.0),
            //           // You can adjust the border radius as needed
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: LoadingFlipping.circle(
        borderColor: Colors.cyan,
        borderSize: 3.0,
        size: 30.0,
        backgroundColor: Colors.cyanAccent,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildPaymentTable(List<Map<String, dynamic>> paymentData) {
    final tableHeaders = ['Month', 'Status', 'Date'];
    final monthField = 'month';
    final statusField = 'status';
    final timestampField = 'timestamp';

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16),
      child: DataTable(
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        columnSpacing: 50,
        columns: tableHeaders.map((header) {
          return DataColumn(
            label: Container(
              alignment: Alignment.center,
              child: Text(header),
            ),
          );
        }).toList(),
        rows: paymentData.map((data) {
          final month = data[monthField]?.toString() ?? '';
          final statusMap = {'true': 'Paid', 'false': 'Unpaid'};
          final statusText =
              statusMap[data[statusField].toString()] ?? 'Unknown';
          final timestamp = data[timestampField] as Timestamp?;
          final formattedTimestamp = timestamp != null
              ? DateFormat.yMMMMd('en_US').format(timestamp.toDate())
              : '--';

          return DataRow(cells: [
            DataCell(Container(
              alignment: Alignment.center,
              child: Text(month),
            )),
            DataCell(Container(
              alignment: Alignment.center,
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusText == 'Paid' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(Container(
              alignment: Alignment.center,
              child: Text(formattedTimestamp),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}

getCurrentUser() {
  FirebaseAuth auth = FirebaseAuth.instance;
  return auth.currentUser;
}

Future<List<Map<String, dynamic>>> fetchData() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('No user is currently logged in');
  }

  try {
    final userId = user.uid;
    final query =
        firestore.collection('maintenance').doc(userId).collection('records');

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } on FirebaseException catch (error) {
    // Handle Firestore-specific errors
    print('Firebase error: ${error.code} - ${error.message}');
    throw Exception('Failed to fetch data: ${error.message}');
  } catch (error) {
    // Handle general errors
    print('General error: $error');
    throw Exception('An unexpected error occurred');
  }
}
