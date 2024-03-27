import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spv/widgets/payment_card.dart';

import 'invoice/invoices.dart';

class Payments extends StatefulWidget {
  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
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
      appBar: AppBar(
        title: Text(
          'Payments',
          style: GoogleFonts.montserrat(
              textStyle: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14.0, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'My Bills',
                    style:
                        GoogleFonts.sourceSans3(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          PaymentCards(paymentData: _paymentData!, onMonthSelected: (selectedMonth) { Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceGenerator(selectedMonth: selectedMonth),
            ),
          ); },)
        ],
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
