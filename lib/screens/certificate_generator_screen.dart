import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pdf_export_util.dart';

class CertificateGeneratorScreen extends StatefulWidget {
  final String internshipTitle;
  const CertificateGeneratorScreen({required this.internshipTitle, super.key});

  @override
  State<CertificateGeneratorScreen> createState() => _CertificateGeneratorScreenState();
}

class _CertificateGeneratorScreenState extends State<CertificateGeneratorScreen> {
  bool loading = false;
  bool generated = false;

  Future<void> _generateCertificate() async {
    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('certificates').add({
      'internshipTitle': widget.internshipTitle,
      'date': DateTime.now().toIso8601String(),
      'downloadUrl': '', // TODO: Add PDF URL after generation
    });
    setState(() {
      loading = false;
      generated = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate generated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Certificate'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 64),
                  const SizedBox(height: 24),
                  Text('Generate certificate for:', style: TextStyle(fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(widget.internshipTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: generated ? null : _generateCertificate,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(generated ? 'Certificate Generated' : 'Generate Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1931),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  if (generated) ...[
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        setState(() => loading = true);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                        final name = userDoc.data()?['name'] ?? '';
                        await PdfExportUtil.exportCertificate(name, widget.internshipTitle, DateTime.now().toIso8601String().split('T').first);
                        setState(() => loading = false);
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
} 