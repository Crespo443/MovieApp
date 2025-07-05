
import 'package:flutter/material.dart';

class Income extends StatelessWidget {
  final int income;

  const Income({super.key, required this.income});

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
            const Icon(Icons.monetization_on, size: 48.0, color: Colors.white),
            const SizedBox(height: 16.0),
            const Text(
              'Income',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8.0),
            Text(
              '\${income.toString()}',
              style: const TextStyle(fontSize: 24.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
