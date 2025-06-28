import 'package:flutter/material.dart';

class NoteWithoutTimer extends StatefulWidget {
  final bool isRunning;
  final bool isPaused;
  final void Function(bool?)? onChanged;
  final bool isCompleted;
  final String text;
  final int? totalDuration; // in seconds
  final int passedSeconds;
  final Duration elapsed;
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
    required this.passedSeconds,
    required this.elapsed,
    required this.isRenewable,
    required this.toggleFavorite,
  });

  @override
  State<NoteWithoutTimer> createState() => _NoteWithoutTimerState();
}

class _NoteWithoutTimerState extends State<NoteWithoutTimer> {
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  

  @override
  Widget build(BuildContext context) {
    final isCountDown = widget.totalDuration != null;
    final remaining = (widget.totalDuration ?? 0) - widget.elapsed.inSeconds;

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
              //condition to check if runnig or pasued or completed
              //also check if the counter was started or not
              if (widget.isRunning ||
                  widget.isPaused ||
                  (widget.totalDuration == null &&
                      widget.isCompleted &&
                      widget.passedSeconds > 0))
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
                                            (remaining / widget.totalDuration!)
                                        : 1,
                                minHeight: 6,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              ),
                            ],
                          )
                          : Text(
                            widget.isCompleted
                                ? "Work done for ${(widget.passedSeconds / 60).ceil()} minutes"
                                : "Active for: ${_formatTime(widget.passedSeconds)}",
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
