import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:myapp/model/repair_concent.dart';
import 'dart:html' as html;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RepairConsentPdfGenerator {
  /// Generates a PDF for the Repair Consent Form.
  static Future<Uint8List> generateConsentPdf({
    required RepairRequestModel request,
    Uint8List? signature,
  }) async {
    final pdf = pw.Document();

    // Load Korean font from assets
    final fontData =
        await rootBundle.load('assets/font/NotoSansKR-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final fileName =
        'repair_consent_${DateTime.now().millisecondsSinceEpoch}.pdf';
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Section
              _buildHeader(ttf, formattedDate),

              pw.SizedBox(height: 10),

              // Customer Name & Contact - Device Password & Loan Phone
              _buildTwoFieldRow(
                "고객명",
                request.customerName,
                "연락처",
                request.contact,
                ttf,
              ),
              // Residence
              _buildSingleFieldRow("거주지역/동", request.residence, ttf,
                  isRequired: true),

              // Device Model
              _buildSingleFieldRow("기종", request.deviceModel, ttf,
                  isRequired: true),

              _buildTwoFieldRow(
                "기기 비밀번호", request.devicePassword,
                "임대폰 여부",
                request.hasLoanPhone.isEmpty ? "" : request.hasLoanPhone,
                ttf,
                isLabel2Required: false, // Loan phone is optional
              ),

              // Issue Details Section
              _buildBoxWithTitle(
                "고장 증상",
                _buildCheckBoxGroup(request.issueDetails, ttf),
                ttf,
              ),

              // Repair Details Section
              _buildBoxWithTitle(
                "수리 내용",
                _buildCheckBoxGroup(request.repairDetails, ttf),
                ttf,
              ),
              pw.SizedBox(height: 5),

              // Detailed Issue Description and Repair Cost
              _buildField("고장 증상 세부내역", request.detailedIssue, ttf),
              _buildField("수리 금액", "\${request.repairCost} 원", ttf),

              // Repair Consent Notes
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Text(
                  "< 수리 의뢰 시 주의사항 >",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ]),

              _buildNoticeParagraph(ttf),

              pw.SizedBox(height: 8),

              // Privacy Consent Section
              _buildSectionTitle("개인정보 수집 동의 (필수)", ttf),
              _buildPrivacyAgreement(ttf),
              pw.SizedBox(height: 3),
              pw.Row(children: [
                _buildCheckBox(request.requiredConsent, '동의함', ttf),
                pw.SizedBox(width: 10),
                _buildCheckBox(!request.requiredConsent, '동의 안함', ttf)
              ]),

              pw.SizedBox(height: 8),

              // Event Agreement Section
              _buildSectionTitle("이벤트 활용 동의 및 광고 수신 동의 (선택)", ttf),
              _buildEventAgreement(ttf),
              pw.SizedBox(height: 3),
              _buildCheckBox(request.requiredConsent, 'SMS, SNS 수신동의(선택)', ttf),

              pw.SizedBox(height: 10),

              // Signature Section (Always at the bottom)
              _buildSignatureSection(request.customerName, signature, ttf),
            ],
          );
        },
      ),
    );

    final Uint8List pdfData = await pdf.save();

    if (isWeb()) {
      // **웹 환경**: 브라우저 다운로드 트리거
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return pdfData;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // **모바일(Android/iOS)**: 로컬 파일 저장
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(pdfData);

      return pdfData; // 저장된 파일 경로 반환
    } else {
      throw UnsupportedError('지원되지 않는 플랫폼입니다.');
    }
  }

  /// Builds the header section with title.
  static pw.Widget _buildHeader(pw.Font ttf, String formattedDate) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Text("✓ ", style: pw.TextStyle(font: ttf, color: PdfColors.red)),
        pw.Text("  필수 입력 부탁드립니다 ",
            style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold))
      ]),
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        color: PdfColors.blue100,
        child: pw.Center(
          child: pw.Text(
            "수리의뢰서",
            style: pw.TextStyle(
              font: ttf,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(' 계좌번호 : 새마을 / 9003-2885-7867-0 / 장정현',
              style: pw.TextStyle(font: ttf, fontSize: 11)),
          pw.Text('작성일 : $formattedDate ',
              style: pw.TextStyle(font: ttf, fontSize: 11)),
        ],
      ),
    ]);
  }

  /// Builds a section title with bold formatting.
  static pw.Widget _buildSectionTitle(String title, pw.Font ttf) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: ttf,
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  /// Builds a labeled field.
  static pw.Widget _buildField(String label, String value, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "$label: ",
            style: pw.TextStyle(
              font: ttf,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: ttf, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a labeled field with optional red check icon.
  static pw.Widget _buildFieldWithIcon(
    String label,
    String value,
    pw.Font ttf, {
    bool isRequired = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        children: [
          if (isRequired)
            pw.Text("✓ ", style: pw.TextStyle(font: ttf, color: PdfColors.red)),
          pw.Text(
            "$label: ",
            style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(font: ttf),
          ),
        ],
      ),
    );
  }

  /// Builds a Two-Field Row with Table layout (1:2:1:2).
  static pw.Widget _buildTwoFieldRow(
      String label1, String value1, String label2, String value2, pw.Font ttf,
      {bool isLabel2Required = true}) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(children: [
          _buildTableCell(label1, ttf, isBold: true, isRequired: true),
          _buildTableCell(value1, ttf),
          _buildTableCell(label2, ttf,
              isBold: true, isRequired: isLabel2Required),
          _buildTableCell(value2, ttf),
        ]),
      ],
    );
  }

  /// Builds a Single-Field Row with Table layout (1:5).
  static pw.Widget _buildSingleFieldRow(String label, String value, pw.Font ttf,
      {bool isRequired = true}) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(5),
      },
      children: [
        pw.TableRow(children: [
          _buildTableCell(label, ttf, isBold: true, isRequired: isRequired),
          _buildTableCell(value, ttf),
        ]),
      ],
    );
  }

  /// Builds a Table Cell
  static pw.Widget _buildTableCell(String text, pw.Font ttf,
      {bool isBold = false, bool isRequired = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (isRequired)
            pw.Text("✓ ", style: pw.TextStyle(font: ttf, color: PdfColors.red)),
          pw.Text(
            text,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a titled box with a specific content widget.
  static pw.Widget _buildBoxWithTitle(
      String title, pw.Widget content, pw.Font ttf) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.black),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 80,
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.grey300,
            child: pw.Text(title,
                style: pw.TextStyle(
                    font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a group of checkboxes for issues or repair details.
  static pw.Widget _buildCheckBoxGroup(Map<String, bool> items, pw.Font ttf) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 4,
      children: items.entries.map((entry) {
        return _buildCheckBox(entry.value, entry.key, ttf);
      }).toList(),
    );
  }

  static pw.Widget _buildCheckBox(bool isCheck, String text, pw.Font ttf) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: isCheck
              ? pw.Center(
                  child:
                      pw.Text("✓", style: pw.TextStyle(font: ttf, fontSize: 8)))
              : pw.Container(),
        ),
        pw.SizedBox(width: 4),
        pw.Text(text, style: pw.TextStyle(font: ttf, fontSize: 9)),
      ],
    );
  }

  /// Builds the Privacy Agreement section.
  static pw.Widget _buildPrivacyAgreement(pw.Font ttf) {
    return pw.Text(
      "본 수리센터의 이벤트 참여 등을 위해 아래와 같이 개인정보를 수집·이용합니다.\n"
      "수집 목적: 이벤트 안내 / 수집 항목: 성명, 전화번호 / 보유 기간: 3년",
      style: pw.TextStyle(font: ttf, fontSize: 8),
    );
  }

  /// Builds the Event Agreement section.
  static pw.Widget _buildEventAgreement(pw.Font ttf) {
    return pw.Text(
      "수리 안내 및 이벤트 공지(ex. 배터리 무료 교체) 등 다양한 정보를 제공합니다.\n"
      "SMS, SNS 수신 동의 여부에 체크해주세요.",
      style: pw.TextStyle(font: ttf, fontSize: 8),
    );
  }

  /// Builds the signature section with customer name and optional signature.
  static pw.Widget _buildSignatureSection(
      String customerName, Uint8List? signature, pw.Font ttf) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text("이름: $customerName",
            style: pw.TextStyle(font: ttf, fontSize: 10)),
        pw.SizedBox(width: 10),
        if (signature != null)
          pw.Image(pw.MemoryImage(signature), width: 80, height: 40)
        else
          pw.Text("[서명]",
              style: pw.TextStyle(font: ttf, color: PdfColors.grey)),
      ],
    );
  }

  /// Builds a section for notice paragraph.
  static pw.Widget _buildNoticeParagraph(pw.Font ttf) {
    final noticeText = [
      "1. 외부 충격이나 침수에 의한 고장 수리의 경우 회로의 이상 오작동이 발생할 수 있습니다.",
      "2. 메인보드 수리 중 데이터 유실이나 이상 증상이 발생할 수 있습니다.",
      "3. 기기의 비밀번호를 입력해 주시기 바랍니다.",
      "4. 부품 교체 시 교체 메시지가 표시될 수 있습니다.",
      "5. 후면 유리 수리 시 추가 비용이 발생할 수 있습니다.",
      "6. 수리 완료 후 입금 확인 시 출고됩니다.",
      "7. 수리 보증 기간은 6개월입니다.",
      "8. 수리 후 정식센터에서 리퍼 및 수리가 불가할 수 있습니다.",
      "9. 수리 후 방수 및 방진 기능이 저하될 수 있습니다.",
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: noticeText.map((line) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(
            line,
            style: pw.TextStyle(font: ttf, fontSize: 8),
          ),
        );
      }).toList(),
    );
  }

  static bool isWeb() {
    try {
      return identical(0, 0.0);
    } catch (e) {
      return false;
    }
  }
}
