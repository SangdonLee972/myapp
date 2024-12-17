import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class ExcelExportService {
  // 엑셀 파일 생성
  static Future<Uint8List> generateExcel(
      List<Map<String, dynamic>> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // 헤더 작성
    List<String> headers = ['이름', 'IMEI', '연락처', '은행', '예금주'];
    sheet.insertRowIterables(headers.map((e) => TextCellValue(e)).toList(), 0);

    // 데이터 작성
    for (int i = 0; i < data.length; i++) {
      var record = data[i];
      sheet.insertRowIterables(
        [
          TextCellValue(record['name'] ?? ''),
          TextCellValue(record['imei'] ?? ''),
          TextCellValue(record['contact'] ?? ''),
          TextCellValue(record['bank'] ?? ''),
          TextCellValue(record['accountHolder'] ?? ''),
        ],
        i + 1,
      );
    }

    // 저장 및 반환
    var bytes = excel.save();
    return Uint8List.fromList(bytes!);
  }

  static bool _isDownloading = false; // 중복 호출 방지

  static Future<void> saveExcelFile(
      String fileName, Uint8List excelData) async {
    if (_isDownloading) return; // 이미 다운로드 중이면 실행하지 않음
    _isDownloading = true;

    try {
      if (kIsWeb) {
        // 웹 플랫폼: AnchorElement를 사용한 파일 다운로드
        final blob = html.Blob([excelData]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..style.display = "none";
        html.document.body!.append(anchor);
        anchor.click(); // 클릭 이벤트 한 번만 실행
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      } else {
        // 모바일/데스크탑 플랫폼: 파일 저장
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(excelData);
        print('File saved to $filePath');
      }
    } catch (e) {
      print("Error saving file: $e");
    } finally {
      _isDownloading = false; // 다운로드 상태 초기화
    }
  }
}
