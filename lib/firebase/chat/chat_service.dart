import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/firebase/chat/message.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUser() {
    final String? currentUserEmail = auth.currentUser?.email;
    return firestore.collection('Users').snapshots().map((snapshots) {
      return snapshots.docs
          .map((doc) => doc.data())
          .where((user) => user['email'] != currentUserEmail)
          .cast<Map<String, dynamic>>()
          .toList();
    });
  }

  //send message
  Future<void> sendMessage(String receivedId, message) async {
    //get user info
    final String currentUserId = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    //new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receivedId,
      message: message,
      timestamp: timestamp,
    );
    //chat room
    List<String> ids = [currentUserId, receivedId];
    ids.sort(); //ensures 2 ppl have same id
    String chatRoomId = ids.join('_');
    //add new message to database
    await firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('message')
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessage(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
