import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class RepairContentPdfGenerater {
  /// PDF 생성 및 저장
  static Future<String> generateContract({
    required String name,
    required String phone,
    required String date,
    Uint8List? signature,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 제목
              pw.Text(
                '매매 계약서',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),

              // 성명
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Text('성명: $name'),
              ),
              pw.SizedBox(height: 8),

              // 전화번호
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Text('전화번호: $phone'),
              ),
              pw.SizedBox(height: 8),

              // 날짜
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Text('날짜: $date'),
              ),
              pw.SizedBox(height: 16),

              // 서명란
              pw.Text('서명:', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              if (signature != null)
                pw.Image(pw.MemoryImage(signature), height: 100),
              if (signature == null)
                pw.Container(
                  height: 100,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Center(
                    child: pw.Text('서명란'),
                  ),
                ),
            ],
          );
        },
      ),
    );

    //return pdf;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/contract.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}
