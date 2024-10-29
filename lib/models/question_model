class QuestionModel {
  final String id; // Unique question ID
  final String questionText;
  final String authorId; // ID of the user who asked the question
  final String topicId; // ID of the topic
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.authorId,
    required this.topicId,
    required this.createdAt,
  });

  // Convert QuestionModel to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'authorId': authorId,
      'topicId': topicId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a QuestionModel from a Map
  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    try {
      return QuestionModel(
        id: map['id'] ?? '',
        questionText: map['questionText'] ?? 'No question provided',
        authorId: map['authorId'] ?? 'Unknown',
        topicId: map['topicId'] ?? 'General',
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(), // Default to now if date is missing
      );
    } catch (e) {
      print('Error parsing QuestionModel: $e');
      rethrow; // Optionally, rethrow to handle it elsewhere
    }
  }

}
