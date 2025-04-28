import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'application_details_screen.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('applications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final applications = snapshot.data!.docs;
          if (applications.isEmpty) {
            return const Center(child: Text('No applications yet.', style: TextStyle(color: Colors.black54)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = applications[i].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: ListTile(
                  title: Text(data['jobTitle'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${data['status'] ?? ''}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationDetailsScreen(
                          jobTitle: data['jobTitle'] ?? '',
                          company: data['company'] ?? '',
                          status: data['status'] ?? '',
                          dateApplied: data['dateApplied'] ?? '',
                          feedback: data['feedback'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 