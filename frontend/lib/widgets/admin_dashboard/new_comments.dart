
import 'package:flutter/material.dart';

class NewComments extends StatelessWidget {
  final int comments;

  const NewComments({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.comment, size: 48.0, color: Colors.white),
            const SizedBox(height: 16.0),
            const Text(
              'New Comments',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              comments.toString(),
              style: const TextStyle(fontSize: 24.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
