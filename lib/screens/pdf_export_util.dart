import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportUtil {
  static Future<void> exportResume(Map<String, dynamic> resumeData) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Resume', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Name: ${resumeData['name'] ?? ''}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Email: ${resumeData['email'] ?? ''}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Text('Education:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(resumeData['education'] ?? ''),
            pw.SizedBox(height: 8),
            pw.Text('Experience:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(resumeData['experience'] ?? ''),
            pw.SizedBox(height: 8),
            pw.Text('Skills:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(resumeData['skills'] ?? ''),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> exportCertificate(String name, String internshipTitle, String date) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Certificate of Completion', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text('This is to certify that', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Text(name, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('has successfully completed the internship in', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Text(internshipTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Date: $date', style: pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
} 