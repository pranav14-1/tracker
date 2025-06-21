import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreService {
  // get collection of notes
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    "notes",
  );

  // CREATE : add a new note
  Future<void> addNote(String note) {
    final user = FirebaseAuth.instance.currentUser;
    return notes.add({
      'note': note,
      'userId': user?.uid ?? '',
      'timestamp': Timestamp.now(),
      'completions': {},
    });
  }

  Future<void> markCompletion(String docID, String date) async {
    final docRef = notes.doc(docID);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentCompletions = Map<String, bool>.from(
        doc['completions'] ?? {},
      );

      // toggle completions based on marking scheme
      final currentStatus = currentCompletions[date] ?? false;
      currentCompletions[date] = !currentStatus;

      await docRef.update({
        'completions': currentCompletions,
        'lastUpdated': Timestamp.now(),
      });
    }
  }

  // GET COMPLETIONS: Stream for heatmap data
  Stream<DocumentSnapshot> getNoteCompletions(String docID) {
    return notes.doc(docID).snapshots();
  }

  // READ : get notes from database
  Stream<QuerySnapshot> getNotesStream() {
    final user = FirebaseAuth.instance.currentUser;
    return notes
        .where('userId', isEqualTo: user?.uid ?? '')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // UPDATE: update notes given a doc id
  Future<void> updateNotes(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE : delete notes given a doc id
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // Saving First time the app has launched
  Future<void> saveFirstLaunchTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists ||
        !(docSnapshot.data()?['firstLaunchTime'] is Timestamp)) {
      await userDoc.set({
        'firstLaunchTime': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  // retrieve the first time the app has launched
  Future<Timestamp?> getFirstLaunchTime() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);

    final docSnapshot = await userDoc.get();

    return docSnapshot.data()?['firstLaunchTime'];
  }
}
