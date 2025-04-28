import 'package:flutter/material.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final String jobTitle;
  final String company;
  final String status;
  final String dateApplied;
  final String feedback;
  const ApplicationDetailsScreen({
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.dateApplied,
    this.feedback = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jobTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A1931))),
            const SizedBox(height: 8),
            Text(company, style: const TextStyle(fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(status, style: TextStyle(fontSize: 16, color: status == 'Accepted' ? Colors.green : status == 'Rejected' ? Colors.red : Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Date Applied: $dateApplied', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (feedback.isNotEmpty) ...[
              const Text('Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(feedback, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
} 