import 'dart:io';
import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spv/pages/profile_page.dart';
import 'package:spv/pages/society_payment.dart';

class InvoiceGenerator extends StatefulWidget {
  @override
  _InvoiceGeneratorState createState() => _InvoiceGeneratorState();
}

class _InvoiceGeneratorState extends State<InvoiceGenerator> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateAndOpenInvoice(String userId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 65),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back,
                      size: 30,)
                    ),
                    const SizedBox(
                      width: 272,
                    ),
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
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://img.freepik.com/premium-vector/young-smiling-man-holding-pointing-blank-screen-laptop-computer-distance-elearning-education-concept-3d-vector-people-character-illustration-cartoon-minimal-style_365941-927.jpg',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: EdgeInsets.only(top: 20, left:30),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Download Invoice !',
                          style: GoogleFonts.abel(
                            textStyle: const TextStyle(
                                fontSize: 35,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50,),
              EaseInAnimation(
                duration: Duration(seconds: 2),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0,right: 30),
                  child: Text('Download invoice of all the maintenance bill paid by you in PDF form for further usage.',
                  style: GoogleFonts.abel(
                    textStyle: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w600)
                  ),),
                ),
              ),
              SizedBox(height: 150,),
              ElevatedButton(
                onPressed: () {
                  // Replace 'userId' with the actual user ID
                  generateAndOpenInvoice('userId');
                },
                child: Text('Generate and Open Invoice'),
                style:ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )

                ),
              ),

            ],
        )


        );
  }
}
