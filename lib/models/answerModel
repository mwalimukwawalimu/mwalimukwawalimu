class Answer {
  final String id;
  final String userID;
  final String name;
  final String time;
  final String questionID;
  final String answerText;
  int likeCount;
  int dislikeCount;
  List<String> replies;

  Answer({
    required this.id,
    required this.userID,
    required this.name,
    required this.questionID,
    required this.time,
    required this.answerText,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.replies = const [],
  });

  // Convert an Answer object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'userID': userID,
      'name': name,
      'questionID': questionID,
      'time': time,
      'answerText': answerText,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'replies': replies,
    };
  }

  // Create an Answer object from Firestore data
  factory Answer.fromFirestore(String id, Map<String, dynamic> data) {
    return Answer(
      id: id,
      name: data['name'] ?? '',
      userID: data['userID'] ?? '',
      questionID: data['questionID'] ?? '',
      time: data['time'] ?? '',
      answerText: data['answerText'] ?? '',
      likeCount: data['likeCount'] ?? 0,
      dislikeCount: data['dislikeCount'] ?? 0,
      replies:
          data['replies'] != null ? List<String>.from(data['replies']) : [],
    );
  }

  // Add a reply
  void addReply(String reply) {
    replies.add(reply);
  }

  // Remove a reply
  void removeReply(String reply) {
    replies.remove(reply);
  }

  // Increment like count
  void incrementLikes() {
    likeCount++;
  }

  // Increment dislike count
  void incrementDislikes() {
    dislikeCount++;
  }
}
