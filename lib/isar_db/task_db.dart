import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracker/isar_db/task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDB extends ChangeNotifier {
  static late Isar isar;

  // Initialize Isar
  static Future<void> init() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open([TaskSchema], directory: dir.path);
    } else {
      isar = Isar.getInstance()!;
    }
  }

  // Load all tasks
  static Future<List<Task>> getTasks() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return[];

    return await isar.tasks.filter().userIdEqualTo(currentUser.uid).findAll();
  }

  // Add new task
  static Future<void> addTask(String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final task = Task()..text = text
    ..userId = currentUser.uid;
    // ..completed = false;
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }

  // Delete a task
  static Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
  }

  // Update task text
  static Future<void> updateTaskText(int id, String newText) async {
    final task = await isar.tasks.get(id);
    if (task != null) {
      task.text = newText;
      await isar.writeTxn(() async {
        await isar.tasks.put(task);
      });
    }
  }

  // Update checkbox (completion status)
  static Future<void> updateTaskCompletion(int id, bool completed) async {
    final task = await isar.tasks.get(id);
    if (task != null) {
      task.completed = completed;
      await isar.writeTxn(() async {
        await isar.tasks.put(task);
      });
    }
  }
}
