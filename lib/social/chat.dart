import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_chat.dart';

class ChatsPage extends StatefulWidget {
  final String currentUserId;

  ChatsPage({required this.currentUserId});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('messages').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final messages = snapshot.data!.docs;

          // Group messages by chat participants
          Map<String, List<DocumentSnapshot>> groupedChats = {};

          messages.forEach((message) {
            final participants = message['participants'] as List<dynamic>;
            final chatId = participants.join();

            if (!groupedChats.containsKey(chatId)) {
              groupedChats[chatId] = [];
            }

            groupedChats[chatId]!.add(message);
          });

          return ListView.builder(
            itemCount: groupedChats.length,
            itemBuilder: (context, index) {
              final chatId = groupedChats.keys.elementAt(index);
              final chatMessages = groupedChats[chatId]!;
              final lastMessage = chatMessages.last;
              final participants = lastMessage['participants'] as List<dynamic>;

              return ChatPreview(
                chatId: chatId,
                lastMessage: lastMessage['text'] ?? '',
                participants: participants,
              );
            },
          );
        },
      ),
    );
  }
}

class ChatPreview extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final List<dynamic> participants;

  ChatPreview({
    required this.chatId,
    required this.lastMessage,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    // For simplicity, display the last participant as the chat name
    final chatName = participants.last;
    String currentUserId = ''; // Initialize with an empty string

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid; // Assign the current user ID
    }

    return ListTile(
      title: Text(chatName),
      subtitle: Text(lastMessage),
      onTap: () {
        // Navigate to the chat page when the user taps on a chat preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(currentUserId: currentUserId,),
          ),
        );
      },
    );
  }
}


