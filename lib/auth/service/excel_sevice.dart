import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class ExcelExportService {
  // 엑셀 파일 생성

  static Future<Uint8List> generateExcel({
    required List<Map<String, dynamic>> purchaseData,
    required List<Map<String, dynamic>> repairData,
  }) async {
    var excel = Excel.createExcel();

    // Sheet1: 매매동의서
    Sheet purchaseSheet = excel['Purchase Agreements'];
    purchaseSheet.insertRowIterables(
      [
        TextCellValue('이름'),
        TextCellValue('IMEI'),
        TextCellValue('연락처'),
        TextCellValue('은행'),
        TextCellValue('예금주'),
      ],
      0,
    );

    for (int i = 0; i < purchaseData.length; i++) {
      var record = purchaseData[i];
      purchaseSheet.insertRowIterables(
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

    // Sheet2: 수리동의서
    Sheet repairSheet = excel['Repair Agreements'];
    repairSheet.insertRowIterables(
      [
        TextCellValue('고객명'),
        TextCellValue('연락처'),
        TextCellValue('기종'),
        TextCellValue('거주지역/동'),
        TextCellValue('기기 비밀번호'),
        TextCellValue('고장증상'),
        TextCellValue('수리내용'),
        TextCellValue('수리비용'),
        TextCellValue('이벤트 활용 동의')
      ],
      0,
    );

    for (int i = 0; i < repairData.length; i++) {
      var record = repairData[i];
      repairSheet.insertRowIterables(
        [
          TextCellValue(record['customerName'] ?? ''),
          TextCellValue(record['contact'] ?? ''),
          TextCellValue(record['deviceModel'] ?? ''),
          TextCellValue(record['residence'] ?? ''),
          TextCellValue(record['devicePassword'] ?? ''),
          TextCellValue(_formatMap(record['issueDetails'] ?? {})),
          TextCellValue(_formatMap(record['repairDetails'] ?? {})),
          TextCellValue(record['repairCost'] ?? ''),
          TextCellValue(record['selectiveConsent'] ?? ''),
        ],
        i + 1,
      );
    }

    // 저장 및 반환
    var bytes = excel.save();
    return Uint8List.fromList(bytes!);
  }

// Map 데이터를 문자열로 변환하는 헬퍼 함수
  static String _formatMap(Map<String, bool> map) {
    return map.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
  }

  // 엑셀 파일 저장
  static Future<void> saveExcelFile(
      String fileName, Uint8List excelData) async {
    try {
      if (kIsWeb) {
        // 웹 플랫폼: AnchorElement를 사용한 파일 다운로드
        final blob = html.Blob([excelData]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..style.display = "none";
        html.document.body!.append(anchor);
        anchor.click(); // 클릭 이벤트 실행
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
    }
  }
}
