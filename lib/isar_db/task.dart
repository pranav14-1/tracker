import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  late String text;
  @Index()
  late final String userId;
  bool completed = false;
}
