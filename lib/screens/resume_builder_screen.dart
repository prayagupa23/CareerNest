import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pdf_export_util.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String education = '';
  String experience = '';
  String skills = '';
  bool loading = false;

  Future<void> _saveResume() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('resume').doc('main').set({
      'name': name,
      'email': email,
      'education': education,
      'experience': experience,
      'skills': skills,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    setState(() => loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (v) => name = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (v) => email = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Education'),
                      onChanged: (v) => education = v,
                      validator: (v) => v == null || v.isEmpty ? 'Enter your education' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Experience'),
                      onChanged: (v) => experience = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Skills'),
                      onChanged: (v) => skills = v,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1931),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Save Resume'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        setState(() => loading = true);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('resume').doc('main').get();
                        if (doc.exists) {
                          await PdfExportUtil.exportResume(doc.data()!);
                        }
                        setState(() => loading = false);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export as PDF'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 