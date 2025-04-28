import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_app/models/job.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;
  final bool isEmployer;
  const JobDetailsScreen({required this.job, this.isEmployer = false, super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _applied = false;
  bool _loading = false;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
    _checkIfBookmarked();
  }

  Future<void> _checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('jobs').doc(widget.job.id).get();
    final applicants = (doc.data()?['applicants'] ?? []) as List<dynamic>;
    setState(() {
      _applied = applicants.any((a) => a['uid'] == user.uid);
    });
  }

  Future<void> _checkIfBookmarked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('bookmarks').doc(widget.job.id).get();
    setState(() {
      _bookmarked = doc.exists;
    });
  }

  Future<void> _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('bookmarks').doc(widget.job.id);
    if (_bookmarked) {
      await ref.delete();
      setState(() => _bookmarked = false);
    } else {
      await ref.set(widget.job.toMap());
      setState(() => _bookmarked = true);
    }
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['name'] ?? '';
    final jobRef = FirebaseFirestore.instance.collection('jobs').doc(widget.job.id);
    await jobRef.update({
      'applicants': FieldValue.arrayUnion([
        {'name': name, 'uid': user.uid, 'status': 'Applied'}
      ])
    });
    // Add to user's applications subcollection
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('applications').doc(widget.job.id).set({
      'jobTitle': widget.job.title,
      'company': widget.job.company,
      'status': 'Applied',
      'dateApplied': DateTime.now().toIso8601String(),
      'feedback': '',
    });
    setState(() {
      _applied = true;
      _loading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(job.title.isNotEmpty ? job.title : 'No Title',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A1931)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(job.company.isNotEmpty ? job.company : 'No Company',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            if (job.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: job.tags.map((t) => Chip(label: Text(t), backgroundColor: const Color(0xFFF7F9FC), labelStyle: const TextStyle(color: Color(0xFF0A1931)))).toList(),
              ),
            if (job.tags.isNotEmpty) const SizedBox(height: 12),
            Row(
              children: [
                const Text('Salary:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A1931))),
                const SizedBox(width: 8),
                Flexible(child: Text(job.salary.isNotEmpty ? job.salary : 'Not specified', style: const TextStyle(color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(job.description.isNotEmpty ? job.description : 'No description provided.', style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 16),
            const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(job.requirements.isNotEmpty ? job.requirements : 'No requirements specified.', style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                const SizedBox(width: 8),
                Text(
                  job.status.isNotEmpty ? job.status : 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    color: job.status == 'Open' ? Colors.green : job.status == 'Closed' ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.isEmployer) ...[
              const Text('Applicants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (job.applicants.isEmpty)
                const Text('No applicants yet.', style: TextStyle(color: Colors.black54)),
              ...job.applicants.map((a) => ListTile(
                leading: CircleAvatar(child: Text(a['name'][0])),
                title: Text(a['name']),
                subtitle: Text('Status: ${a['status']}'),
              )),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Edit Job'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1931),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applied || _loading ? null : _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1931),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_applied ? 'Applied' : 'Apply'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF0A1931)),
                    tooltip: _bookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 