
import 'package:flutter/material.dart';

class WatchingHours extends StatelessWidget {
  final int hours;

  const WatchingHours({super.key, required this.hours});

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
            const Icon(Icons.watch_later, size: 48.0, color: Colors.white),
            const SizedBox(height: 16.0),
            const Text(
              'Watching Hours',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              hours.toString(),
              style: const TextStyle(fontSize: 24.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
