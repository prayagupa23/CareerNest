import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String requirements = '';
  String salary = '';
  String status = 'Open';
  bool loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    await FirebaseFirestore.instance.collection('jobs').add({
      'title': title,
      'description': description,
      'requirements': requirements,
      'salary': salary,
      'status': status,
      'applicants': [],
      'createdAt': DateTime.now(),
    });
    setState(() => loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Job'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Job Title'),
                      onChanged: (v) => title = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter job title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onChanged: (v) => description = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Requirements'),
                      maxLines: 2,
                      onChanged: (v) => requirements = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter requirements' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Salary'),
                      onChanged: (v) => salary = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter salary' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: const [
                        DropdownMenuItem(value: 'Open', child: Text('Open')),
                        DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                      ],
                      onChanged: (v) => setState(() => status = v ?? 'Open'),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1931),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Post Job'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 