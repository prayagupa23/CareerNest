import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationTimelineScreen extends StatelessWidget {
  final String appId;
  const ApplicationTimelineScreen({required this.appId, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Timeline'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('applications').doc(appId).collection('timeline').orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final timeline = snapshot.data!.docs;
          if (timeline.isEmpty) {
            return const Center(child: Text('No updates yet.', style: TextStyle(color: Colors.black54)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: timeline.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, i) {
              final data = timeline[i].data() as Map<String, dynamic>;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, color: i == timeline.length - 1 ? Colors.green : Colors.blue, size: 18),
                      if (i != timeline.length - 1)
                        Container(width: 2, height: 40, color: Colors.blue[200]),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(data['date'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        if ((data['note'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(data['note'], style: const TextStyle(fontSize: 14)),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
} 