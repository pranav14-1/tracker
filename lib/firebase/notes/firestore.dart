import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreService {
  /// Returns a reference to the current user's notes collection
  CollectionReference get _userNotes {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return FirebaseFirestore.instance
        .collection('user_notes')
        .doc(user.uid)
        .collection('notes');
  }

  /// Adds a new note with optional countdown duration (in minutes)
  Future<void> addNote(String note, [int? durationMins]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Ensure the user document exists
    await FirebaseFirestore.instance
        .collection('user_notes')
        .doc(user.uid)
        .set({}, SetOptions(merge: true));

    final Map<String, dynamic> noteData = {
      'note': note,
      'timestamp': Timestamp.now(),
      'completions': {},
      'dayLimit': 1,
      'isRenewable': false,
    };

    if (durationMins != null && durationMins > 0) {
      noteData.addAll({
        'isRunning': false,
        'elapsedSeconds': 0,
        'totalDuration': durationMins * 60,
      });
    }

    await _userNotes.add(noteData);
  }

  /// Toggles completion for the given note on a specific date
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

  /// Returns a stream of the current user's notes, ordered by creation time
  Stream<QuerySnapshot> getNotesStream() {
    try {
      return _userNotes.orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      return Stream.empty();
    }
  }

  /// Updates a note's text and optionally its timer
  Future<void> updateNotes(
    String docID,
    String newNote, [
    int? durationMins,
  ]) async {
    final Map<String, dynamic> updateData = {
      'note': newNote,
      'timestamp': Timestamp.now(),
    };

    if (durationMins != null && durationMins > 0) {
      updateData['totalDuration'] = durationMins * 60;
    } else {
      updateData['totalDuration'] = FieldValue.delete();
    }

    await _userNotes.doc(docID).update(updateData);
  }

  /// Deletes a note by its ID
  Future<void> deleteNote(String docID) async {
    await _userNotes.doc(docID).delete();
  }

  // Toggle the note as favourite or not
  Future<void> toggleFavorite(String docID, bool CurrentStatus) async {
    await _userNotes.doc(docID).update({
      'isRenewable' : !CurrentStatus,
    });
  }

  // Start the timer and save the data

  /// Starts or pauses the timer on a note
  Future<void> toggleTimer(Map<String, dynamic> task, String docId) async {
    final docRef = _userNotes.doc(docId);

    if (task['isRunning'] == true && task['startTime'] != null) {
      // PAUSE: Calculate elapsed time and stop timer
      final startTime = (task['startTime'] as Timestamp).toDate();
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      final totalElapsed = (task['elapsedSeconds'] ?? 0) + elapsed;

      await docRef.update({
        'isRunning': false,
        'startTime': FieldValue.delete(),
        'elapsedSeconds': totalElapsed,
      });
    } else {
      // START: Begin/resume timer
      await docRef.update({'isRunning': true, 'startTime': Timestamp.now()});
    }
  }

  /// Stops and resets the timer for a note
  Future<void> stopTimer(String docId) async {
    final docRef = _userNotes.doc(docId);

    await docRef.update({
      'isRunning': false,
      'startTime': FieldValue.delete(),
      'elapsedSeconds': 0,
    });
  }
}
