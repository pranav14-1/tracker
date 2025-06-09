import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracker/firebase/chat/chat_bubble.dart';
import 'package:tracker/firebase/chat/chat_service.dart';
import 'package:tracker/firebase/log_sign/auth.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({super.key, required this.receiverEmail, required this.receiverId});

  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(receiverId, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail), centerTitle: true),
      body: Column(
        children: [
          // Display all messages
          Expanded(child: buildMessageList()),

          // User input
          buildUserInput(),
        ],
      ),
    );
  }

  // Message list
  Widget buildMessageList() {
    final senderId = AuthService.getCurrentUser()!.uid;

    return StreamBuilder(
      stream: chatService.getMessage(receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading messages"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(8),
          children:
              snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Single message UI
  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == AuthService.getCurrentUser()!.uid;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        child: ChatBubble(message: data['message'], isCurrentUser: isSender),
      ),
    );
  }

  // Message input row
  Widget buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Enter Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          margin: EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
