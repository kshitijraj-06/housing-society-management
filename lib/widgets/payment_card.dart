import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCards extends StatefulWidget {
  final List<Map<String, dynamic>> paymentData;
  final Function(String) onMonthSelected;

  PaymentCards({required this.paymentData, required this.onMonthSelected});

  @override
  State<PaymentCards> createState() => _PaymentCardsState();
}

class _PaymentCardsState extends State<PaymentCards> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount:
            (widget.paymentData.length / 2).ceil(), // Calculate number of rows
        itemBuilder: (context, index) {
          final startIndex = index * 2;
          final endIndex = startIndex + 2;
          return Row(
            children: widget.paymentData
                .sublist(
                    startIndex,
                    endIndex < widget.paymentData.length
                        ? endIndex
                        : widget.paymentData.length)
                .map((payment) {
              return Expanded(
                child: buildPaymentCard(payment),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildPaymentCard(Map<String, dynamic> payment) {
    final userId = FirebaseAuth.instance.currentUser;
    final month = payment['month']?.toString() ?? '';
    final amount = payment['amount']?.toString() ?? '';
    final invoice = payment['invoice']?.toString() ?? '';
    final statusMap = {'true': 'Paid', 'false': 'Unpaid'};
    final statusText = statusMap[payment['status'].toString()] ?? 'Unknown';

    Color bgColor;

    switch (statusText) {
      case 'Paid':
        bgColor = Colors.blue;
        break;
      default:
        bgColor = Colors.white;
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          generateAndOpenInvoice('userId', month);
        },
        child: Card(
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹ $amount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                Text(
                  month,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  invoice,
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                getStatusWidget(statusText)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateAndOpenInvoice(String userId, String selectedMonth) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;

    // Retrieve user's name
    String? userName;
    String? flat;
    String? block;
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        userName = userSnapshot.get('name');
        flat = userSnapshot.get('flatNumber');
        block = userSnapshot.get('block');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('maintenance')
          .doc(userId)
          .collection('records')
          .where('month', isEqualTo: selectedMonth) // Filter by selected month
          .get();

      // Create a PDF document in memory
      final pdf = pw.Document();
      final imageJpg = (await rootBundle.load('assets/images/logo.png'))
          .buffer
          .asUint8List();
      final totalAmount = querySnapshot.docs
          .fold(0.0, (sum, doc) => sum + (doc.get('amount')))
          .toStringAsFixed(2);

      // Add user information to the invoice
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            {
              return [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 20),
                      alignment: pw.Alignment.center,
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text('Maintenance bill for $userName',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 20)),
                                pw.SizedBox(width: 80),
                                pw.Image(
                                  pw.MemoryImage(imageJpg),
                                  width: 100,
                                  height: 100,
                                ),
                              ]),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('To,'),
                          pw.SizedBox(width: 364),
                          pw.Text('From,'),
                          // pw.Text('Spring valley Phase - I'),
                        ]),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('$userName,'),
                          pw.SizedBox(
                            width: 299,
                          ),
                          pw.Text('Spring Valley Phase - 1,')
                        ]),
                    pw.Row(children: [
                      pw.Text('$flat - $block Block,'),
                      pw.SizedBox(width: 310),
                      pw.Text('Lalpur'),
                    ]),
                    pw.Row(children: [
                      pw.Text('Spring valley Phase - I'),
                      pw.SizedBox(width: 261),
                      pw.Text('Ranchi, Jharkhand - 834001'),
                    ]),
                    pw.SizedBox(height: 100),
                    if (querySnapshot.docs.isNotEmpty)
                      pw.Table.fromTextArray(
                        context: context,
                        headerStyle:
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        cellAlignment: pw.Alignment.center,
                        headerDecoration:
                        pw.BoxDecoration(color: PdfColors.grey300),
                        cellHeight: 30,
                        data: [
                          // Include only relevant headers
                          ['Month', 'Invoice Number', 'Amount', 'Total'],
                          // Move total calculation and formatting outside the loop
                          // Iterate over documents excluding the first element (total row)
                          for (QueryDocumentSnapshot doc
                          in querySnapshot.docs.skip(0))
                            [
                              doc.id,
                              doc.get('invoice'),
                              doc.get('amount'),
                            ],
                          [' ', ' ', ' ', totalAmount],
                        ],
                        columnWidths: {
                          0: pw.FixedColumnWidth(50),
                          1: pw.FixedColumnWidth(50),
                        },
                        border: null,
                      ),
                    pw.SizedBox(height: 220),
                    pw.Text(
                        '-----------------------------------------------------------------------------------------------------------------------'),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                            'Spring Valley Phase - 1, Lower Burdwan Compund, Lalpur, Ranchi, Jharkhand - 834001',
                            style: pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                )
              ];
            }
          },
        ),
      );

      // Get the directory where the PDF will be saved
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/invoice_$userId.pdf';

      // Save the PDF to a file
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      // Open the PDF using a PDF viewer
      OpenFile.open(path);

      print('Invoice generated and opened successfully!');
    } catch (e) {
      print('Error generating invoice: $e');
    }
  }

  Widget getStatusWidget(String statusText) {
    Color statusColor;
    Color bgColor;
    switch (statusText) {
      case 'Paid':
        statusColor = Colors.white;
        bgColor = Colors.lightBlueAccent;
        break;
      default:
        statusColor = Colors.black;
        bgColor = Colors.red.shade200;
    }
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.sourceSans3(
            textStyle:
                TextStyle(fontSize: 12, color: statusColor.withOpacity(1))),
      ),
    );
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
}
