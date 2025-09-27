import 'package:flutter/material.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key});

  // Future<void> _generatePdf(BuildContext context) async {
  //   try {
  //     final pdf = pw.Document();

  //     pdf.addPage(
  //       pw.Page(
  //         build: (pw.Context context) => pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text(
  //               "Skin Analysis Report",
  //               style:
  //                   pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
  //             ),
  //             pw.SizedBox(height: 12),
  //             _buildReportSection(
  //                 "Skin Type", "Oily skin with a tendency for acne breakouts."),
  //             _buildReportSection(
  //                 "Pores", "Enlarged pores observed around the T-zone."),
  //             _buildReportSection(
  //                 "Pigmentation", "Mild hyperpigmentation detected on cheeks."),
  //             _buildReportSection("Recommended Routine",
  //                 "Use oil-free moisturizers and SPF 50 sunscreen daily."),
  //           ],
  //         ),
  //       ),
  //     );

  //     await Printing.layoutPdf(
  //       onLayout: (PdfPageFormat format) async => pdf.save(),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to generate PDF: $e")),
  //     );
  //   }
  // }

  // pw.Widget _buildReportSection(String title, String description) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.Text(title,
  //           style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //       pw.SizedBox(height: 4),
  //       pw.Text(description, style: pw.TextStyle(fontSize: 14)),
  //       pw.Divider(thickness: 1),
  //       pw.SizedBox(height: 6),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      // child: ElevatedButton.icon(
      //   onPressed: () => _generatePdf(context),
      //   icon: const Icon(Icons.download),
      //   label: const Text("Download Report"),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.blueAccent,
      //     foregroundColor: Colors.white,
      //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //   ),
      // ),
    );
  }
}
