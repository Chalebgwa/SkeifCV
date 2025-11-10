import 'dart:typed_data';
import 'package:cv_generator/models/cv_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<Uint8List> generateCv(CvData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(data.fullName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(data.email),
              pw.Text(data.phoneNumber),
              pw.SizedBox(height: 20),
              pw.Text('Work Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...data.workExperience.map(
                (exp) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(exp.jobTitle, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(exp.company),
                    pw.Text(exp.dates),
                    pw.Text(exp.description),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Education', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...data.education.map(
                (edu) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(edu.institution, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(edu.degree),
                    pw.Text(edu.dates),
                    pw.Text(edu.description),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...data.skills.map((skill) => pw.Text(skill)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
