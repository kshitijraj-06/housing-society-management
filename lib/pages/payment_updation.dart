import 'package:animated_flutter_widgets/animated_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spv/pages/profile_page.dart';

class SocietyMaintenanceUpdation extends StatefulWidget {
  const SocietyMaintenanceUpdation({super.key});

  @override
  _SocietyMaintenanceUpdation createState() => _SocietyMaintenanceUpdation(users: []);
}

class _SocietyMaintenanceUpdation extends State<SocietyMaintenanceUpdation> {
  final List<String> months = List.generate(
      12, (index) => DateFormat('MMMM').format(DateTime(2024, index + 1)));
  List<Map<String, dynamic>> users;
  TextEditingController _InvoiceController = TextEditingController();
  String? selectedUser;
  int _selectedIndex = DateTime.now().month - 1;
  String? selectedStatus;
  bool _isPaid = false;

  _SocietyMaintenanceUpdation({required this.users});

  @override
  void initState() {
    super.initState();
    fetchUsersFromFirestore(); // Call method to fetch users from Firestore
  }

  void dispose() {
    _InvoiceController.dispose();
    super.dispose();
  }


  Future<void> fetchUsersFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        users = querySnapshot.docs.map((doc) {
          print('Document ID: ${doc.id}');
          print('Document Data: ${doc.data()}');
          return {
            'userId': doc.id,
            'name': doc['quantity'],
          };
        }).toList();
      });
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (users == null) {
      return CircularProgressIndicator();
    } else {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 65, left: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 30),
                      ),
                      const SizedBox(
                        width: 265,
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
                        child: const CircleAvatar(
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
                  duration: const Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, left: 29),
                    child: Row(
                      children: [
                        Text(
                          'Society Maintenance - Update',
                          style: GoogleFonts.abel(
                            textStyle: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Select User'),
                      value: selectedUser,
                      items: users.map<DropdownMenuItem<String>>((user) {
                        return DropdownMenuItem<String>(
                          value: user['userId'],
                          child: Text(user['name']),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedUser = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select User',
                        helperText:
                            'Choose the user for which the Maintenance is to be Updated',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EaseInAnimation(
                  duration: const Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<int>(
                      isExpanded: false,
                      value: _selectedIndex,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      items: months
                          .asMap()
                          .entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedIndex = value!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Month',
                        helperText:
                            'Choose the month for the updation of Monthly Maintenance.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EaseInAnimation(
                  duration: Duration(seconds: 1),
                  child: TextFormField(
                    controller: _InvoiceController,
                    maxLines: 4,
                    decoration: new InputDecoration(
                      labelText: "Enter Description",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        // Check if complaint is empty
                        return "Description cannot be empty";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isPaid,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _isPaid = value!;
                        });
                      },
                    ),
                    Text('Paid',
                        style: GoogleFonts.abel(
                            textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ))),
                    const SizedBox(width: 30),
                    Checkbox(
                      value: !_isPaid,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _isPaid = !value!;
                        });
                      },
                    ),
                    Text(
                      'Unpaid',
                      style: GoogleFonts.abel(
                          textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                EaseInAnimation(
                  duration: const Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        updateMaintenance();
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Update Maintenance'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black), // Change background color
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Change text color
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            // You can adjust the border radius as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    }
  }

  Future<void> updateMaintenance() async {
    String month = months[_selectedIndex];
    String? userId = selectedUser?.toString();
    String invoice = _InvoiceController.text;// Ensure selectedUser is not null

    if (userId != null) { // Check if userId is valid
      try {
        await FirebaseFirestore.instance
            .collection('maintenance')
            .doc(userId) // Use userId directly if correct
            .collection('records')
            .doc(month)
            .set({
          'userId': userId, // Redundant since userId is used in the document path
          'status': _isPaid,
          'timestamp': FieldValue.serverTimestamp(),
          'month': month,
          'amount' : 2000,
          'invoice' : invoice,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Maintenance record updated successfully!'),
          backgroundColor: Colors.green,
        ));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
          Text('Failed to update maintenance record. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a valid user.'),
      ));
    }
  }
}
