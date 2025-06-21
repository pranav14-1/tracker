import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreService {
  // get collection of notes
  CollectionReference get _userNotes {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return FirebaseFirestore.instance
        .collection('user_notes')
        .doc(user.uid)
        .collection('notes');
  }

  // CREATE : add a new note
  Future<void> addNote(String note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // create user document if not exists
    await FirebaseFirestore.instance
        .collection('user_notes')
        .doc(user.uid)
        .set({}, SetOptions(merge: true));

    // Add notes to user's subcollection
    await _userNotes.add({
      'note': note,
      'timestamp': Timestamp.now(),
      'completions': {},
    });
  }

  Future<void> markCompletion(String docID, String date) async {
    final docRef = _userNotes.doc(docID);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentCompletions = Map<String, bool>.from(
        doc['completions'] ?? {},
      );

      final currentStatus = currentCompletions[date] ?? false;
      currentCompletions[date] = !currentStatus;

      await docRef.update({
        'completions': currentCompletions,
        'lastUpdated': Timestamp.now(),
      });
    }
  }

  // READ: Get notes stream for current user
  Stream<QuerySnapshot> getNotesStream() {
    try {
      return _userNotes.orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      return Stream.empty();
    }
  }

  // UPDATE: Update note text
  Future<void> updateNotes(String docID, String newNote) {
    return _userNotes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: Delete note
  Future<void> deleteNote(String docID) {
    return _userNotes.doc(docID).delete();
  }

  // Saving first launch time (now in user document)
  Future<void> saveFirstLaunchTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('user_notes')
        .doc(user.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists ||
        !(docSnapshot.data()?['firstLaunchTime'] is Timestamp)) {
      await userDoc.set({
        'firstLaunchTime': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  // Retrieve first launch time
  Future<Timestamp?> getFirstLaunchTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final docSnapshot =
        await FirebaseFirestore.instance
            .collection('user_notes')
            .doc(user.uid)
            .get();

    return docSnapshot.data()?['firstLaunchTime'];
  }
}
