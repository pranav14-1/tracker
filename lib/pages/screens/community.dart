import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker/components/userTile.dart';
import 'package:tracker/firebase/chat/chatPage.dart';
import 'package:tracker/firebase/chat/chat_service.dart';
import 'package:tracker/firebase/log_sign/auth.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  //chat and auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COM-N-CON',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
            decorationThickness: 2,
          ),
        ),
      ),
      body: SafeArea(child: builderList()),
    );
  }

  //build a list of user except the current user
  Widget builderList() {
    return StreamBuilder(
      stream: chatService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error!');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        final users = snapshot.data!;
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder:
              (context, index) =>
                  const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return buildUserListItem(users[index], context);
          },
        );
      },
    );
  }

  //build individual list title for user
  Widget buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    //display all users except current user
    return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(receiverEmail: userData["email"]),
          ),
        );
      },
    );
  }
}
