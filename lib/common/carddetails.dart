import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mwalimukwawalimu/common/constants.dart';
import 'package:mwalimukwawalimu/models/answerModel.dart';
import 'package:mwalimukwawalimu/models/database.dart';
import 'package:mwalimukwawalimu/services/firebase_service.dart';
import 'package:mwalimukwawalimu/services/gamification.dart';
import 'package:mwalimukwawalimu/services/notification_service.dart';

class DetailsScreen extends StatefulWidget {
  final String questionId;
  final String author;
  final String question;
  final String authorId;

  const DetailsScreen(
      {super.key,
      required this.questionId,
      required this.author,
      required this.question,
      required this.authorId});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final AnswerService _answerService =
      AnswerService(); // Initialize AnswerService
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int? _replyingToIndex; // To track which answer is being replied to
  late final DocumentSnapshot userDoc;
  late String username = '';
  final FirebaseApi _firebaseApi = FirebaseApi();
  DatabaseService databaseService =
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);

  String targetFCMToken = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
    getToken();
  }

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final Gamification _gamification =
      Gamification(uid: FirebaseAuth.instance.currentUser!.uid);

  Future<void> _initializeUser() async {
    userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      username = userDoc.get('username');
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> getToken() async {
    String token = await databaseService.getUserFCMToken(widget.authorId);
    setState(() {
      targetFCMToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answers section with Firestore integration
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      AssetImage('assets/avatar.jpg'), // Add user image
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.author,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("4h ago", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: [
                Chip(
                  label: const Text('Design'),
                  backgroundColor: Colors.grey.shade200,
                ),
                Chip(
                  label: const Text('Development'),
                  backgroundColor: Colors.grey.shade200,
                ),
                Chip(
                  label: const Text('Development'),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Answer>>(
                stream: _answerService.getAnswers(widget.questionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching answers.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No answers yet.'));
                  }
                  final answers = snapshot.data!;
                  return ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final answer = answers[index];
                      return _buildAnswerItem(answer, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAnswerInputDialog(context);
        },
        backgroundColor: kPrimary,
        child: Image.asset('assets/images/answer.png'),
      ),
    );
  }

  // Function to show the answer input dialog
  void _showAnswerInputDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  hintText: 'Write your answer...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_answerController.text.isNotEmpty) {
                    try {
                      final answer = Answer(
                        id: uid, // User's ID for answer
                        name: username, // User's name
                        userID: uid, // User's ID
                        questionID: widget.questionId,
                        time: DateTime.now().toIso8601String(),
                        answerText: _answerController.text,
                      );

                      //send notification to author
                      await _firebaseApi.sendNotification(
                          targetFCMToken: targetFCMToken,
                          title: "Likes",
                          body:
                              "Someone answered your question '${widget.question}'",
                          data: {
                            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            'post_id': '12345',
                          });
                      // Upload answer to Firestore
                      await _answerService.addAnswer(widget.questionId, answer);
                      await _gamification.updateScore('answer');

                      _answerController.clear();
                      Navigator.pop(context); // Close the dialog on success
                    } catch (e) {
                      print('Error submitting answer: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to submit answer')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: kPrimary,
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(color: kOffWhite),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Build answer item with like, dislike, and reply functionality
  Widget _buildAnswerItem(Answer answer, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(answer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(answer.time,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(answer.answerText),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showReplyDialog(context, answer);
                          },
                          child: const Text('Reply'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.thumb_up_alt_outlined,
                            color: kPrimary,
                          ),
                          onPressed: () {
                            _answerService.updateLikeCount(widget.questionId,
                                answer.id, answer.likeCount + 1);
                          },
                        ),
                        Text('${answer.likeCount}'),
                        IconButton(
                          icon: const Icon(
                            Icons.thumb_down_alt_outlined,
                            color: kPrimary,
                          ),
                          onPressed: () {
                            _answerService.updateDislikeCount(widget.questionId,
                                answer.id, answer.dislikeCount + 1);
                          },
                        ),
                        Text('${answer.dislikeCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies Section
          StreamBuilder<List<String>>(
            stream: _answerService.getReplies(widget.questionId, answer.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Text('Error fetching replies.'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Text('No replies yet.'),
                );
              }
              final replies = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: replies.length,
                itemBuilder: (context, replyIndex) {
                  final replyText = replies[replyIndex];
                  return _buildReplyItem(replyText);
                },
              );
            },
          ),
          const Divider(), // Divider between answers for clarity
        ],
      ),
    );
  }

  Widget _buildReplyItem(String replyText) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 5.0, bottom: 5.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 15,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Time',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Text(replyText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, Answer answer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply'),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_replyController.text.isNotEmpty) {
                  try {
                    // Save the reply
                    await _answerService.addReply(
                      widget.questionId,
                      answer.id,
                      _replyController.text,
                    );
                    await _gamification.updateScore('reply');
                    _replyController.clear();
                    Navigator.of(context).pop(); // Close the dialog on success
                  } catch (e) {
                    print('Error adding reply: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add reply')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Reply input field
  Widget _buildReplyInput(Answer answer, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (_replyController.text.isNotEmpty) {
                try {
                  await _answerService.addReply(
                    widget.questionId,
                    answer.id,
                    _replyController.text,
                  );
                  setState(() {
                    _replyingToIndex = null;
                  });
                  _replyController.clear();
                } catch (e) {
                  print('Error adding reply: $e');
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

