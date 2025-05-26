import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tracker/features/dialog.dart';
import 'package:tracker/features/tasks.dart';

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
  bool checked = false;

  List activity = [
    ["Activity App Flutter", false],
    ["Go Gym", false],
    ["Eat", false],
    ["Sleep", false],
    ["Study", false],
  ];

  void boxChanged(bool? value, int index) {
    setState(() {
      activity[index][1] = !activity[index][1];
    });
  }

  void newTask() {
    showDialog(
      context: context,
      builder: (context) {
        return TaskDialog();
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
            color: Colors.white,
            fontSize: 25,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
            decorationThickness: 2,
          ),
        ),
        // elevation: 1,
        // shadowColor: Colors.grey,
        centerTitle: true,
        backgroundColor: Colors.black,
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
            // SizedBox(height: 20),
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
              child: ListView.builder(
                itemCount: activity.length,
                itemBuilder: (context, index) {
                  return Tasks(
                    taskname: activity[index][0],
                    taskcompleted: activity[index][1],
                    onChanged: (value) => boxChanged(value, index),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
