import 'package:flutter/material.dart';

class NoteWithoutTimer extends StatefulWidget {
  final bool isRunning;
  final bool isPaused;
  final void Function(bool?)? onChanged;
  final bool isCompleted;
  final String text;
  final int? totalDuration; // in seconds
  final bool isRenewable;
  final void Function()? toggleFavorite;

  const NoteWithoutTimer({
    super.key,
    required this.totalDuration,
    required this.isPaused,
    required this.isRunning,
    required this.onChanged,
    required this.isCompleted,
    required this.text,
    required this.isRenewable,
    required this.toggleFavorite,
  });

  @override
  State<NoteWithoutTimer> createState() => _NoteWithoutTimerState();
}

class _NoteWithoutTimerState extends State<NoteWithoutTimer> {  

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null &&
            widget.isRunning == false &&
            widget.isPaused == false) {
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
              if (widget.totalDuration != null)
                Text(
                  "${(widget.totalDuration! / 60).round()} min timer",
                  style: TextStyle(
                    color:
                        widget.isCompleted ? Colors.white70 : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          leading: Checkbox(
            activeColor: Colors.grey,
            value: widget.isCompleted,
            onChanged: widget.onChanged,
          ),
          trailing: IconButton(
            onPressed: widget.toggleFavorite,
            icon: Icon(Icons.autorenew),
            color:
                widget.isRenewable
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
