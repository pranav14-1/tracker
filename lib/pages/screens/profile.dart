import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:tracker/components/my_app_bar.dart';
import 'package:tracker/firebase/log_sign/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController bubbleController = TextEditingController();

  // Field for the username
  String? username;
  bool isLoadingUsername = false;

  String bubbleText = '';

  static const double _avatarRadius = 36;
  static const double _bubbleHeight = 28.0;
  static const double _charWidth = 12.0;

  @override
  void dispose() {
    bubbleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      // Assume username is always present in Firestore and non-null
      setState(() {
        username = data!['username'] as String;
        isLoadingUsername = false;
      });
    } else {
      // Edge case: If doc somehow doesn't exist, you can handle it by throwing or logging
      setState(() {
        username = '';
        isLoadingUsername = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: MyAppBar(text: "Profile"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: _avatarRadius,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          bubbleController.text = bubbleText;
                          final text = await showDialog<String>(
                            context: context,
                            builder:
                                (dialogCtx) => StatefulBuilder(
                                  builder:
                                      (ctx, setStateDialog) => AlertDialog(
                                        title: Text('Set Thought Bubble'),
                                        content: TextField(
                                          controller: bubbleController,
                                          autofocus: true,
                                          maxLength: 20,
                                          decoration: InputDecoration(
                                            hintText:
                                                "Your thought… (max 20 chars)",
                                            counterText: "",
                                            suffixIcon:
                                                bubbleController.text.isNotEmpty
                                                    ? IconButton(
                                                      icon: Icon(Icons.clear),
                                                      onPressed: () {
                                                        bubbleController
                                                            .clear();
                                                        setStateDialog(
                                                          () {},
                                                        ); // for dialog's UI
                                                      },
                                                    )
                                                    : null,
                                          ),
                                          onChanged:
                                              (_) => setStateDialog(() {}),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  ctx,
                                                  bubbleController.text.trim(),
                                                ),
                                            child: Text('Save'),
                                          ),
                                        ],
                                      ),
                                ),
                          );
                          if (text != null) {
                            setState(() {
                              bubbleText = text;
                            });
                          }
                          bubbleController.clear();
                        },
                        child: BubbleThought(
                          text: bubbleText,
                          charWidth: _charWidth,
                          height: _bubbleHeight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoadingUsername ? 'Loading...' : (username ?? 'Loading..'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        user?.email ?? user?.phoneNumber ?? "No user info",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.group, size: 16, color: Colors.green),
                          SizedBox(width: 5),
                          Text(
                            'Friends: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('0', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.redAccent),
                  onPressed: () async {
                    await AuthService.logout();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2.0, top: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatTile(
                    icon: Icons.local_fire_department,
                    label: "Streak",
                    value: "0",
                    iconColor: Colors.orange,
                  ),
                  SizedBox(height: 12),
                  StatTile(
                    icon: Icons.access_time,
                    label: "Hours Worked",
                    value: "0",
                    iconColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleThought extends StatelessWidget {
  final String text;
  final double charWidth;
  final double height;

  const BubbleThought({
    required this.text,
    this.charWidth = 12.0,
    this.height = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final int fixedCharCount = 4;
    final double minWidth = text.length * charWidth + 24; // for <4 chars
    final double fixedWidth = charWidth * fixedCharCount + 24; // for ≥4 chars
    final bool needsMarquee = text.length > fixedCharCount;

    final double bubbleWidth =
        text.isEmpty
            ? 40
            : (text.length < fixedCharCount ? minWidth : fixedWidth);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontStyle: FontStyle.italic,
    );

    return Container(
      width: bubbleWidth,
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child:
          text.isEmpty
              ? Icon(Icons.add_comment, color: Colors.white, size: 16)
              : needsMarquee
              ? Marquee(
                text: text,
                style: textStyle,
                scrollAxis: Axis.horizontal,
                blankSpace: 16,
                velocity: 20.0,
                pauseAfterRound: Duration(seconds: 1),
                startPadding: 5,
                accelerationDuration: Duration(seconds: 1),
                decelerationDuration: Duration(seconds: 1),
              )
              : Text(
                text,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
    );
  }
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        SizedBox(width: 7),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(value, style: TextStyle(fontSize: 15)),
      ],
    );
  }
}
