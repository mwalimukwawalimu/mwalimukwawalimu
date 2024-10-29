import 'package:flutter/material.dart';

// A separate widget for the trending discussion card
class TrendingDiscussionCard extends StatelessWidget {
  final String title;
  final String joined;
  final String messages;

  const TrendingDiscussionCard({super.key, 
    required this.title,
    required this.joined,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Set the card's border radius
      ),
      elevation: 5,
      margin: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 200, // Defined width of the card
        height: 100, // Defined height of the card
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(joined, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.message, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(messages, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
