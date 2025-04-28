import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_details_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  String stipend = '';
  bool workFromHome = false;
  String skill = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Minimum Stipend'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => stipend = v),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: workFromHome,
                      onChanged: (v) => setState(() => workFromHome = v ?? false),
                    ),
                    const Text('Work from home'),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Skill Required'),
                  onChanged: (v) => setState(() => skill = v),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                if (stipend.isNotEmpty) {
                  docs = docs.where((doc) => (doc['stipend'] ?? 0) >= int.tryParse(stipend)!).toList();
                }
                if (workFromHome) {
                  docs = docs.where((doc) => doc['workFromHome'] == true).toList();
                }
                if (skill.isNotEmpty) {
                  docs = docs.where((doc) => (doc['skills'] ?? '').toString().toLowerCase().contains(skill.toLowerCase())).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No results found.', style: TextStyle(color: Colors.black54)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Stipend: ${data['stipend'] ?? ''}'),
                        trailing: data['workFromHome'] == true ? const Icon(Icons.home, color: Colors.green) : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailsScreen(data: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 