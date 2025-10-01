import 'package:flutter/material.dart';

class RetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RetryView({
    super.key,
    this.message = "Something went wrong",
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sad Smiley
          Text(
            "☹️",
            style: TextStyle(fontSize: 50, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Retry Button
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
