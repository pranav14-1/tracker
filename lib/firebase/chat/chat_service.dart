import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

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
}
