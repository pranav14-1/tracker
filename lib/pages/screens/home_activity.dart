import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/components/my_heat_map.dart';
import 'package:tracker/components/note_tile.dart';
import 'package:tracker/features/dialogBox.dart';
import 'package:tracker/firebase/notes/firestore.dart';
import 'package:tracker/theme/switchButton.dart';
import 'package:intl/intl.dart';
import 'package:tracker/theme/themeSwitch.dart';

String avatar(dynamic value) =>
    'https://api.dicebear.com/7.x/adventurer/png?seed=$value';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeAtivityState();
}

class _HomeAtivityState extends State<HomeActivity> {
  // Text Controller
  final noteController = TextEditingController();
  final durationController = TextEditingController();

  bool isCompleted = false;

  // firestore service
  final FireStoreService fireStoreService = FireStoreService();

  void addNewTask() async {
    final note = noteController.text.trim();
    final durationText = durationController.text.trim();
    final durationMins = int.tryParse(durationText);
    // add a new note to the server
    if (note.isNotEmpty) {
      await fireStoreService.addNote(note, durationMins);

      // Clear inputs
      noteController.clear();
      durationController.clear();

      // Close the dialog or screen
      Navigator.pop(context);
    }
  }

  // edit habit box
  void editHabitBox(String docID, String noteText, int? totalDuration) {
    // set the controller's text to the current note's name
    noteController.text = noteText;
    durationController.text =
        totalDuration != null ? (totalDuration ~/ 60).toString() : '';

    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          noteController: noteController,
          durationController: durationController,
          onAdd: () {
            final note = noteController.text.trim();
            final durationText = durationController.text.trim();
            final durationMins = int.tryParse(durationText);
            fireStoreService.updateNotes(docID, note, durationMins);
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
    noteController.clear();
    durationController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          noteController: noteController,
          durationController: durationController,
          onAdd: addNewTask,
          onAddText: "Add",
          onCancel: () {
            noteController.clear();
            durationController.clear();
            Navigator.of(context).pop();
          },
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          // Initialize datasets for heatmap
          Map<DateTime, int> heatmapDatasets = {};
          List<DocumentSnapshot> notesList = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            notesList = snapshot.data!.docs;

            // Build heatmap datasets from completion data
            for (var doc in notesList) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              Map<String, dynamic> completions =
                  (data['completions'] as Map<String, dynamic>?) ?? {};

              completions.forEach((dateStr, isCompleted) {
                if (isCompleted == true) {
                  DateTime date = DateTime.parse(dateStr);
                  // Normalize date to remove time component
                  DateTime normalizedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );
                  heatmapDatasets[normalizedDate] =
                      (heatmapDatasets[normalizedDate] ?? 0) + 1;
                }
              });
            }
          }

          // Calculate start date (last 3 months)
          DateTime startDate = DateTime.now().subtract(Duration(days: 30));

          return Column(
            children: [
              // Heatmap Calendar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MyHeatMap(
                  isDarkMode: Provider.of<ThemeSwitch>(context).isDarkMode,
                  startDate: startDate,
                  datasets: heatmapDatasets,
                ),
              ),
              // Notes List
              if (notesList.isEmpty)
                Expanded(
                  child: Center(child: Text("No notes yet. Tap + to add one!")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notesList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];
                      Map<String, dynamic> completions =
                          (data['completions'] as Map<String, dynamic>?) ?? {};
                      bool isCompletedToday =
                          completions[today] as bool? ?? false;

                      //Extract totalDuration (in seconds) from Firestore
                      int? totalDuration = data['totalDuration'];

                      return NoteTile(
                        isCompleted: isCompletedToday,
                        text: noteText,
                        onChanged: (value) async {
                          await fireStoreService.markCompletion(docID, today);
                        },
                        editHabit:
                            (context) =>
                                editHabitBox(docID, noteText, totalDuration),
                        deleteHabit: (context) => deleteHabitBox(docID),
                        totalDuration: totalDuration,
                        // toggleTimer: (context) {
                        //   fireStoreService.toggleTimer(data, docID);
                        // },
                      );
                    },
                  ),
                ),
            ],
          );
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
