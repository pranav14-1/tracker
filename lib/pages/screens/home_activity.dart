import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tracker/components/note_tile.dart';
import 'package:tracker/features/dialogBox.dart';
import 'package:tracker/features/taskslist.dart';
import 'package:tracker/firebase/notes/firestore.dart';
import 'package:tracker/theme/switchButton.dart';
import 'package:intl/intl.dart';

String avatar(dynamic value) =>
    'https://api.dicebear.com/7.x/adventurer/png?seed=$value';

class HomeAtivity extends StatefulWidget {
  const HomeAtivity({super.key});

  @override
  State<HomeAtivity> createState() => _HomeAtivityState();
}

class _HomeAtivityState extends State<HomeAtivity> {
  // Text Controller
  final _controller = TextEditingController();

  bool isCompleted = false;

  // firestore service
  final FireStoreService fireStoreService = FireStoreService();

  void addNewTask() {
    // add a new note to the server
    fireStoreService.addNote(_controller.text);

    // clear the text controller
    _controller.clear();

    Navigator.pop(context);
  }

  // edit habit box
  void editHabitBox(String docID, String noteText) {
    // set the controller's text to the current note's name
    _controller.text = noteText;

    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          controller: _controller,
          onAdd: () {
            fireStoreService.updateNotes(docID, _controller.text);
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

  void toggleValue() {
    setState(() {
      isCompleted = !isCompleted;
    });
  }

  void newTask() {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          controller: _controller,
          onAdd: addNewTask,
          onAddText: "Add",
          onCancel: Navigator.of(context).pop,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'TRACKER',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
            decorationThickness: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [ThemeSwitchButton()],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            // display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;
                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Get completion status directly from documents
                Map<String, dynamic> completions =
                    (data['completions'] as Map<String, dynamic>?) ?? {};
                bool isCompletedToday = completions[today] as bool? ?? false;
                // display as a list tile
                return NoteTile(
                  isCompleted: isCompletedToday,
                  text: noteText,
                  onChanged: (value) async {
                    toggleValue();
                    await fireStoreService.markCompletion(docID, today);
                  },
                  editHabit: (context) => editHabitBox(docID, noteText),
                  deleteHabit: (context) => deleteHabitBox(docID),
                );
              },
            );
          } else {
            return const Text("No notes");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newTask,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
