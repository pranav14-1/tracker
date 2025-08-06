// This file is used for the function of add, update and delete the notes

import 'package:flutter/material.dart';
import 'package:tracker/components/dialogBox.dart';
import 'package:tracker/features/timer%20provider/timer_manager.dart';
import 'package:tracker/features/timer%20provider/timer_provider.dart';
import 'package:tracker/firebase/notes/firestore.dart';
import 'package:tracker/services/note_class/note.dart';

FireStoreService fireStoreService = FireStoreService();

void newTask({required TaskDialogParams params}) async {
  void addNewTask() async {
    final note = params.noteController.text.trim();
    final durationText = params.durationController.text.trim();
    final durationMins = int.tryParse(durationText);
    // add a new note to the server
    if (note.isNotEmpty) {
      await fireStoreService.addNote(note, durationMins);

      // Clear inputs
      params.noteController.clear();
      params.durationController.clear();

      // Close the dialog or screen
      Navigator.pop(params.context);
    }
  }

  params.noteController.clear();
  params.durationController.clear();
  showDialog(
    context: params.context,
    builder: (context) {
      return TaskDialog(
        noteController: params.noteController,
        durationController: params.durationController,
        onAdd: addNewTask,
        onCancel: Navigator.of(context).pop,
        onAddText: "Add",
      );
    },
  );
}

void editHabitBox({
  required String docID,
  required String noteText,
  required int? totalDuration,
  required TaskDialogParams params,
}) {
  // Set the controller's text to the current note's values
  params.noteController.text = noteText;
  params.durationController.text = totalDuration != null ? (totalDuration ~/ 60).toString() : '';

  showDialog(
    context: params.context,
    builder: (context) {
      return TaskDialog(
        noteController: params.noteController,
        durationController: params.durationController,
        onAdd: () async {
          final note = params.noteController.text.trim();
          final durationText = params.durationController.text.trim();
          final durationMins = int.tryParse(durationText);

          // Update Firestore
          await fireStoreService.updateNotes(docID, note, durationMins);

          // --- Update the TimerProvider duration (if provided) ---
          if (durationMins != null) {
            final totalSeconds = durationMins * 60;
            TimerProvider provider = TimerManager.get(
              docID,
              TimerMode.countdown,
              Duration(seconds: totalSeconds),
            );
            provider.updateDuration(Duration(seconds: totalSeconds));
          }

          Navigator.pop(context);
        },
        onCancel: Navigator.of(context).pop,
        onAddText: "Update",
      );
    },
  );
}


void deleteHabitBox(String docID) {
  fireStoreService.deleteNote(docID);
}
