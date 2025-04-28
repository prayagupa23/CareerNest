import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const CourseDetailsScreen({required this.data, super.key});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool isBookmarked = false;
  bool isApplied = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final bookmark = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('bookmarks').doc(widget.data['id']).get();
    final application = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('applications').doc(widget.data['id']).get();
    setState(() {
      isBookmarked = bookmark.exists;
      isApplied = application.exists;
      loading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('bookmarks').doc(widget.data['id']);
    if (isBookmarked) {
      await ref.delete();
    } else {
      await ref.set(widget.data);
    }
    _checkStatus();
  }

  Future<void> _apply() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('applications').doc(widget.data['id']);
    await ref.set({
      'jobTitle': widget.data['title'],
      'company': widget.data['company'] ?? '',
      'status': 'Applied',
      'dateApplied': DateTime.now().toIso8601String(),
      'feedback': '',
    });
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Course Details'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(data['title'] ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0A1931))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${data['duration'] ?? ''}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${data['rating'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('${data['learners'] ?? ''} learners', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(data['description'] ?? '', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _toggleBookmark,
                    icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1931),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: isApplied ? null : _apply,
                    icon: const Icon(Icons.send),
                    label: Text(isApplied ? 'Applied' : 'Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 