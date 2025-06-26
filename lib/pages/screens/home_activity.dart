import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/components/home_page_component/my_heat_map.dart';
import 'package:tracker/components/home_page_component/note_tile.dart';
import 'package:tracker/components/my_app_bar.dart';
import 'package:tracker/firebase/notes/firestore.dart';
import 'package:tracker/services/note_CRUD_functions.dart';
import 'package:tracker/services/note_class/note.dart';
import 'package:intl/intl.dart';
import 'package:tracker/theme/themeSwitch.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // This is the class which holds the basic component of note adding and deleting
  late TaskDialogParams params;

  // used to track if the note is completed or not
  bool isCompleted = false;

  // firestore service
  final FireStoreService fireStoreService = FireStoreService();

  void toggleValue() {
    setState(() {
      isCompleted = !isCompleted;
    });
  }

  late ValueNotifier<bool> anyTimerRunningNotifier;

  @override
  void initState() {
    super.initState();
    anyTimerRunningNotifier = ValueNotifier(false);
    params = TaskDialogParams(
      context: context,
      noteController: noteController,
      durationController: durationController,
    );
  }

  @override
  void dispose() {
    anyTimerRunningNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now();
    final today_date = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: MyAppBar(text: "TRACKER"),
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

              //counts task completed
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

          // Filtering notes which are supposed to be displayed
          List<DocumentSnapshot> filteredNotes = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty)
            notesList = snapshot.data!.docs;

          // Filter notes based on dayLimit and favourite Status
          // Replace your current filtering logic with this:
          filteredNotes =
              notesList.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                // Always show favorites
                if (data['isRenewable'] == true) return true;

                // Get creation timestamp
                Timestamp? timestamp = data['timestamp'];
                if (timestamp == null) return false;

                DateTime createdAt = timestamp.toDate();

                // Normalize dates to midnight for accurate comparison
                DateTime createdAtDate = DateTime(
                  createdAt.year,
                  createdAt.month,
                  createdAt.day,
                );
                int dayLimit = data['dayLimit'] ?? 1;

                // Calculate expiration date (midnight after last valid day)
                DateTime expirationDate = createdAtDate.add(
                  Duration(days: dayLimit),
                );

                // Check if today is before expiration date
                return today_date.isBefore(expirationDate);
              }).toList();

          // Calculate start date (last 3 months)
          DateTime startDate = DateTime.now().subtract(Duration(days: 90));

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
              if (filteredNotes.isEmpty)
                Expanded(
                  child: Center(child: Text("No notes yet. Tap + to add one!")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = filteredNotes[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];

                      // This is used to track if the task is favourite or not by the user
                      bool isRenewable = data['isRenewable'] ?? false;

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
                            (context) => editHabitBox(
                              docID: docID,
                              noteText: noteText,
                              totalDuration: totalDuration,
                              params: params,
                            ),
                        deleteHabit: (context) => deleteHabitBox(docID),
                        totalDuration: totalDuration,
                        anyTimerRunningNotifier: anyTimerRunningNotifier,
                        toggleFavorite: () async {
                          await fireStoreService.toggleFavorite(
                            docID,
                            isRenewable,
                          );
                          if (!isRenewable) {
                            Fluttertoast.showToast(
                              msg: "Task will renew each day",
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        },
                        isRenewable: isRenewable,
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
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: anyTimerRunningNotifier,
        builder: (context, isRunning, _) {
          return FloatingActionButton(
            onPressed:
                isRunning
                    ? () {
                      Fluttertoast.showToast(
                        msg: "Finish the timer to add a task",
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                    : () {
                      newTask(params: params);
                    },
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: const Icon(Icons.add),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
