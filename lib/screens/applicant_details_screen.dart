import 'package:flutter/material.dart';

class ApplicantDetailsScreen extends StatelessWidget {
  final String name;
  final String job;
  const ApplicantDetailsScreen({required this.name, required this.job, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch applicant details from Firestore using name/job
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicant Details'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 32, child: Text(name.isNotEmpty ? name[0] : '')), 
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Applied for $job', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Status: Pending', style: TextStyle(fontSize: 16, color: Colors.orange)),
            const SizedBox(height: 16),
            const Text('Resume:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('No resume uploaded.'),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 