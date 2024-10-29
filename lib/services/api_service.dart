// services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<String>> getSuggestedTopics(String topicTitle) async {
    final response = await http.post(
      Uri.parse('https://api.example.com/suggest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': topicTitle}),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
