import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mwalimukwawalimu/common/card_detail.dart';
import 'package:mwalimukwawalimu/common/constants.dart';
import 'package:mwalimukwawalimu/models/database.dart';
import 'package:mwalimukwawalimu/services/firebase_service.dart';
import 'package:mwalimukwawalimu/services/gamification.dart';
import 'package:mwalimukwawalimu/services/notification_service.dart';

class CustomCard extends StatefulWidget {
  final String question;
  final String author;
  final String time;
  final String questionId; // Add questionId as a required field
  final String docid;
  final String authorId;
  final VoidCallback onPressed;

  const CustomCard({
    super.key,
    required this.question,
    required this.author,
    required this.time,
    required this.authorId,
    required this.questionId, // Add questionId as a required field
    required this.onPressed,
    required this.docid,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  final FirebaseService _firebaseService = FirebaseService();

  final Gamification _gamification =
      Gamification(uid: FirebaseAuth.instance.currentUser!.uid);

  final FirebaseApi _firebaseApi = FirebaseApi();
  DatabaseService databaseService =
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);

  String targetFCMToken = '';

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    String token = await databaseService.getUserFCMToken(widget.authorId);
    setState(() {
      targetFCMToken = token;
    });
  }

  Future<void> _likeQuestion() async {
    await _firebaseService.likeQuestion(widget.questionId);
    await _firebaseApi.sendNotification(
        targetFCMToken: targetFCMToken,
        title: "Likes",
        body: "Someone liked your question",
        data: {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'post_id': '12345',
        });
    await _gamification.updateScore('like');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
                questionId: widget.questionId,
                question: widget.question,
                authorId: widget.authorId,
                author: widget.author), // Pass questionId here
          ),
        );
      },
      child: SizedBox(
        width: 450,
        height: 250,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar and Author
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.author,
                        style: const TextStyle(color: kDark, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.time,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Middle: Question
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: kDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Row: Buttons and Thumbs Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up, color: kPrimaryLight),
                      onPressed: () {
                        _likeQuestion();
                      },
                    ),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryLight),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                questionId: widget.questionId,
                                author: widget.author,
                                authorId: widget.authorId,
                                question: widget.question,
                              ), // the detail screen is supposed to be here
                            ),
                          );
                        },
                        child: const Text(
                          'See Answer',
                          style: TextStyle(color: kOffWhite),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryLight),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              questionId: widget.questionId,
                              author: widget.author,
                              authorId: widget.authorId,
                              question: widget.question,
                            ), // Pass questionId here
                          ),
                        );
                      },
                      child: const Text(
                        'Give Answer',
                        style: TextStyle(color: kOffWhite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

