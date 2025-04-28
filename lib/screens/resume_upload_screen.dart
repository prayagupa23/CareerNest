import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:open_file/open_file.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  String? fileName;
  String? filePath;
  Database? db;
  final ValueNotifier<List<Map<String, dynamic>>> resumesNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    db = await openDatabase(
      p.join(dbPath, 'resumes.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE resumes(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, path TEXT)',
        );
      },
      version: 1,
    );
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    if (db == null) return;
    final data = await db!.query('resumes');
    resumesNotifier.value = List<Map<String, dynamic>>.from(data);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        fileName = result.files.first.name;
        filePath = result.files.first.path;
      });
    }
  }

  Future<void> _saveResume() async {
    if (db == null || fileName == null || filePath == null) return;
    await db!.insert('resumes', {'name': fileName, 'path': filePath});
    setState(() {
      fileName = null;
      filePath = null;
    });
    _loadResumes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume saved locally!')));
    }
  }

  Future<void> _deleteResume(int id) async {
    if (db == null) return;
    await db!.delete('resumes', where: 'id = ?', whereArgs: [id]);
    _loadResumes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume deleted.')));
    }
  }

  Future<void> _openFile(String path) async {
    if (await File(path).exists()) {
      await OpenFile.open(path);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File not found.')));
      }
    }
  }

  @override
  void dispose() {
    resumesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Resume'),
        backgroundColor: const Color(0xFF0A1931),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Icon(Icons.upload_file, size: 64, color: Color(0xFF0A1931)),
            const SizedBox(height: 24),
            Text(fileName ?? 'No file selected', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1931),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            if (fileName != null)
              ElevatedButton(
                onPressed: _saveResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Save Locally'),
              ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Saved Resumes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: resumesNotifier,
                builder: (context, resumes, _) {
                  if (resumes.isEmpty) {
                    return const Center(child: Text('No resumes saved yet.', style: TextStyle(color: Colors.black54)));
                  }
                  return ListView.separated(
                    itemCount: resumes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final resume = resumes[i];
                      return ListTile(
                        leading: const Icon(Icons.description, color: Color(0xFF0A1931)),
                        title: Text(resume['name'] ?? ''),
                        subtitle: Text(resume['path'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.blue),
                              tooltip: 'Open',
                              onPressed: () => _openFile(resume['path']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _deleteResume(resume['id']),
                            ),
                          ],
                        ),
                        onTap: () => _openFile(resume['path']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 