import 'package:flutter/material.dart';
import 'package:tmdb/core/utilities/common_utilities.dart';

class RetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  RetryView({
    super.key,
    String? message, // nullable
    required this.onRetry,
  }) : message = message ?? "somethingWentWrong".loc; // assign here

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
            label: Text("retry".loc),
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
