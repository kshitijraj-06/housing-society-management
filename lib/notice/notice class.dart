// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// Future<List<Notice>> getNotices() async {
//   // ... (same as previous getNotices function)
// }
//
// class Notice {
//   // ... (same as previous Notice class)
// }
//
// class NoticeGrid extends StatefulWidget {
//   final List<Notice> notices;
//
//   const NoticeGrid({Key? key, required this.notices}) : super(key: key);
//
//   @override
//   State<NoticeGrid> createState() => _NoticeGridState();
// }
//
// class _NoticeGridState extends State<NoticeGrid> {
//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2, // Adjust for desired number of columns
//       mainAxisSpacing: 10.0, // Spacing between rows
//       crossAxisSpacing: 10.0, // Spacing between columns
//       childAspectRatio: 1.6, // Adjust for desired card aspect ratio
//       children: widget.notices.map((notice) => _buildNoticeCard(notice)).toList(),
//     );
//   }
//
//   Widget _buildNoticeCard(Notice notice) {
//     return InkWell(
//       onTap: () {
//         // Handle notice click (e.g., navigate to details page)
//         print('Notice "${notice.title}" clicked!');
//         // Implement your navigation logic here
//       },
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 notice.title,
//                 style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8.0),
//               Text(notice.body),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Firebase.initializeApp();
//
//   final notices = await getNotices();
//
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: const Text('Notices'),
//       ),
//       body: NoticeGrid(notices: notices),
//     ),
//   ));
// }
