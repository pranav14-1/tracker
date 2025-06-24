import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoteTile extends StatefulWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  final int? totalDuration; // in seconds
  final void Function(BuildContext)? toggleTimer;

  const NoteTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    this.totalDuration,
    this.toggleTimer,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  Timer? _timer;
  int passedSeconds = 0;
  bool isRunning = false;

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          passedSeconds++;
          // Stop timer automatically if duration reached
          if (widget.totalDuration != null &&
              passedSeconds >= widget.totalDuration!) {
            _timer?.cancel();
            isRunning = false;
          }
        });
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCountDown = widget.totalDuration != null;
    final remaining = (widget.totalDuration ?? 0) - passedSeconds;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _toggleTimer(),
              icon: isRunning ? Icons.pause : Icons.play_arrow,
              backgroundColor: isRunning ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: widget.deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (widget.onChanged != null) {
              widget.onChanged!(!widget.isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.isCompleted
                      ? Colors.blue
                      : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note text
                  Text(
                    widget.text,
                    style: TextStyle(
                      color:
                          widget.isCompleted
                              ? Colors.white
                              : Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Always show total duration if present
                  if (widget.totalDuration != null)
                    Text(
                      "${(widget.totalDuration! / 60).round()} min timer",
                      style: TextStyle(
                        color:
                            widget.isCompleted
                                ? Colors.white70
                                : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),

                  // Show dynamic timer only when running
                  if (isRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child:
                          isCountDown
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time left: ${_formatTime(remaining > 0 ? remaining : 0)}",
                                    style: TextStyle(
                                      color:
                                          widget.isCompleted
                                              ? Colors.white70
                                              : Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value:
                                        remaining > 0
                                            ? 1 -
                                                (remaining /
                                                    widget.totalDuration!)
                                            : 1,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.green,
                                  ),
                                ],
                              )
                              : Text(
                                "Active for: ${_formatTime(passedSeconds)}",
                                style: TextStyle(
                                  color:
                                      widget.isCompleted
                                          ? Colors.white70
                                          : Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                    ),
                ],
              ),
              leading: Checkbox(
                activeColor: Colors.blue,
                value: widget.isCompleted,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
