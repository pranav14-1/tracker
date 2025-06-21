import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tracker/features/dialogBox.dart';
import 'package:tracker/features/taskslist.dart';
import 'package:tracker/theme/switchButton.dart';
import 'package:tracker/isar_db/task.dart';
import 'package:tracker/isar_db/task_db.dart';

String avatar(dynamic value) =>
    'https://api.dicebear.com/7.x/adventurer/png?seed=$value';

class HomeAtivity extends StatefulWidget {
  const HomeAtivity({super.key});

  @override
  State<HomeAtivity> createState() => _HomeAtivityState();
}

class _HomeAtivityState extends State<HomeAtivity> {
  int currentIndex = 0;
  int currentUserIndex = 2;
  final _controller = TextEditingController();

  List<Task> activity = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    await TaskDB.init();
    final tasks = await TaskDB.getTasks();
    if (!mounted) return;
    setState(() {
      activity = tasks;
    });
  }

  void boxChanged(bool? value, int index) async {
    final task = activity[index];
    await TaskDB.updateTaskCompletion(task.id, value ?? false);
    setState(() {
      activity[index].completed = value ?? false;
    });
  }

  void saveTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await TaskDB.addTask(text);
    _controller.clear();
    await loadTasks();
    Navigator.of(context).pop();
  }

  void newTask() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          controller: _controller,
          onAdd: saveTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) async {
    final task = activity[index];
    await TaskDB.deleteTask(task.id);
    await loadTasks();
  }

  void editTask(int index) {
    final task = activity[index];
    _controller.text = task.text;

    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog(
          controller: _controller,
          onAdd: () async {
            final newText = _controller.text.trim();
            if (newText.isNotEmpty) {
              await TaskDB.updateTaskText(task.id, newText);
              await loadTasks();
            }
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CarouselSlider.builder(
              itemCount: 5,
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: Colors.blue,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: currentIndex == index ? 40 : 30,
                            backgroundImage: CachedNetworkImageProvider(
                              avatar(index),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'User $index',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 200,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                pageSnapping: true,
                initialPage: currentUserIndex,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            Divider(thickness: 1, color: Colors.grey, height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Your tasks: ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  activity.isEmpty
                      ? Center(
                        child: Text(
                          'Add Some Task!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: activity.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: ValueKey(activity[index].id),
                            endActionPane: ActionPane(
                              motion: BehindMotion(),
                              children: [
                                CustomSlidableAction(
                                  onPressed: (context) => editTask(index),
                                  backgroundColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.edit,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                CustomSlidableAction(
                                  onPressed: (context) => deleteTask(index),
                                  backgroundColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.delete,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            child: Tasks(
                              taskname: activity[index].text,
                              taskcompleted: activity[index].completed,
                              onChanged: (value) => boxChanged(value, index),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
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
