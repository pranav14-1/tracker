import 'package:flutter/material.dart';

class TaskDialogParams {
  final BuildContext context;
  final TextEditingController noteController;
  final TextEditingController durationController;

  TaskDialogParams({
    required this.context,
    required this.noteController,
    required this.durationController,
  });
}
