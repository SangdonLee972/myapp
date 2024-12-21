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
    final phoneImage = await rootBundle.load('assets/img/phone.png');
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final customPageFormat = PdfPageFormat(
      PdfPageFormat.a4.width, // A4의 너비 유지
      PdfPageFormat.a4.height + 270, // 기본 높이에 270pt 추가
    );
    try {
      pdf.addPage(
        pw.Page(
          pageFormat: customPageFormat,
          margin: const pw.EdgeInsets.symmetric(vertical: 10),
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
                _buildFaultAndDamageSection(request.isScreenDamaged,
                    request.hasSimCard, request.detailedIssue, phoneImage, ttf),
                // Detailed Issue Description and Repair Cost

                pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      color: const PdfColor.fromInt(0xFFF8CAB4),
                    ),
                    child: pw.Text('*아래 사항은 작성하지 마세요*',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf),
                        textAlign: pw.TextAlign.center)),
                // Repair Details Section
                _buildBoxWithTitle(
                  "수리 내용",
                  _buildCheckBoxGroup(request.repairDetails, ttf),
                  ttf,
                ),
                buildRepairRequestBox(ttf),
                buildRepairAmountSection(
                    request.repairCost,
                    request.reviewOptions,
                    request.hasNaverReservation,
                    request.hasDiscount,
                    ttf),
                pw.SizedBox(height: 5),
                // Repair Consent Notes
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
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
                _buildCheckBox(
                    request.requiredConsent, 'SMS, SNS 수신동의(선택)', ttf),

                pw.SizedBox(height: 10),

                // Signature Section (Always at the bottom)
                _buildSignatureSection(request.customerName, signature, ttf),
                pw.SizedBox(height: 4),
                pw.Container(
                    padding: const pw.EdgeInsets.only(top: 10),
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide())),
                    child: pw.Text('울산아이폰수리센터 픽스애플',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 15,
                            font: ttf),
                        textAlign: pw.TextAlign.center))
              ],
            );
          },
        ),
      );
    } catch (e) {
      print('errptLog:$e');
    }

    try {
      final Uint8List pdfData = await pdf.save();
      print('Saving~');
      if (isWeb()) {
        // **웹 환경**: 브라우저 다운로드 트리거
        final blob = html.Blob([pdfData], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        print('what??');
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
    } catch (e) {
      print('saveErr:$e');
      throw UnsupportedError('저장 중 오류가 발생했습니다.');
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
          _buildTableCenterCell(label1, ttf, isBold: true, isRequired: true),
          _buildTableCell(value1, ttf),
          _buildTableCenterCell(label2, ttf,
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
          _buildTableCenterCell(label, ttf,
              isBold: true, isRequired: isRequired),
          _buildTableCell(value, ttf),
        ]),
      ],
    );
  }

  static pw.Widget _buildFaultAndDamageSection(
    bool hasScreenDamage,
    bool hasSimCard,
    String detailedFault,
    ByteData phoneImage,
    pw.Font ttf,
  ) {
    return pw.Container(
      height: 250, // Adjust the height in points
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Left Section
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Screen Status
                  pw.Expanded(
                    flex: 1,
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  right: pw.BorderSide(color: PdfColors.black)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '액정상태',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              _buildCheckBox(hasScreenDamage, '액정파손 있음', ttf),
                              pw.SizedBox(height: 10),
                              _buildCheckBox(!hasScreenDamage, '액정파손 없음', ttf),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(color: PdfColors.black, height: 1),

                  // SIM Status
                  pw.Expanded(
                    flex: 1,
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  right: pw.BorderSide(color: PdfColors.black)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '유심상태',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              _buildCheckBox(hasSimCard, '유심칩 있음', ttf),
                              pw.SizedBox(height: 10),
                              _buildCheckBox(!hasSimCard, '유심칩 없음', ttf),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(color: PdfColors.black, height: 1),

                  // Issue Details
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  right: pw.BorderSide(color: PdfColors.black)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '고장증상\n세부내역',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '사용자가 입력한 세부내역',
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Section
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            right: pw.BorderSide(color: PdfColors.black)),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '파손상태',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: _buildDamageImage(phoneImage),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTextFieldCell(String value, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        value.isNotEmpty ? value : "입력되지 않음",
        style: pw.TextStyle(font: ttf, fontSize: 9),
      ),
    );
  }

  /// Builds a cell with the damage state image.
  static pw.Widget _buildDamageImage(ByteData phoneImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Image(
        pw.MemoryImage(phoneImage.buffer.asUint8List()),
        fit: pw.BoxFit.contain,
        width: 120,
        height: 150,
      ),
    );
  }

  /// Builds an empty cell.
  static pw.Widget _buildEmptyCell() {
    return pw.Container();
  }

  /// Builds a title cell with centered bold text.
  static pw.Widget _buildTitleCell(String title, pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: pw.Alignment.center,
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: ttf,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
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

  /// Builds a Table Cell
  static pw.Widget _buildTableCenterCell(String text, pw.Font ttf,
      {bool isBold = false, bool isRequired = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (isRequired)
              pw.Text("✓ ",
                  style: pw.TextStyle(font: ttf, color: PdfColors.red)),
            pw.Text(
              text,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ));
  }

  /// Builds a titled box with a specific content widget in a 1:5 Table Layout.
  static pw.Widget _buildBoxWithTitle(
      String title, pw.Widget content, pw.Font ttf) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      columnWidths: const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(5),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Center(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                )),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: content,
            ),
          ],
        ),
      ],
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
        pw.SizedBox(width: 5),
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
    return // 서명 섹션
        pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('판매자 : ',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.Container(
          width: 70,
          child: pw.Text(customerName,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center),
        ),
        pw.SizedBox(width: 10),
        pw.Stack(
          alignment: pw.Alignment.center,
          children: [
            // Signature Image (if present)
            if (signature != null)
              pw.Image(
                pw.MemoryImage(signature),
                fit: pw.BoxFit.contain,
                width: 50, // Adjust width as needed
                height: 20, // Adjust height as needed
              ),
            // Placeholder text
            pw.Text(
              '(인)',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildRepairRequestBox(pw.Font ttf) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.black),
          right: pw.BorderSide(color: PdfColors.black),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Center(
              child: pw.Text(
                '수리의뢰서',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black),
                ),
              ),
              height: 50, // Replace with appropriate size
              child: pw.Center(
                child: pw.Text(
                  '(상위) 와 같은 증상으로 수리를 의뢰 합니다.',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section for notice paragraph.
  static pw.Widget _buildNoticeParagraph(pw.Font ttf) {
    final noticeText = [
      "1. 외부 충격이나 침수에 의한 고장 수리의 경우",
      "   회로의 이상 오작동으로 전원 불량이 발생하여 수리를 할 수 없는 경우가 발생할 수 있습니다.",
      "2. 메인보드 수리 중 데이터 유실이나 이상 증상이 발생할 수 있습니다. 이에 대한 당사의 책임이 없을을 공지 드립니다.",
      "3. 기기의 비밀번호를 적어주시기 바랍니다. 수리 후 기기 점검을 위해 필요합니다.",
      "4. 액정, 카메라, 배터리 등 부품 교체의 경우 교체 메시지가 보일 수 있습니다.",
      "5. 후면 유리 수리 경우, 충격 여부에 따라 메인보드 및 기타 이상 증상 있을 수 있습니다.(추가비용 발생합니다.)",
      "6. 모든 수리는 수리 완료 후 입그해주시는 건에 대해 당일 출고가 진행됩니다.",
      "7. 수리 보증 기간은 6개월입니다.(단 고객과실 시 유상수리 진행)",
      "8. 수리 후 정식센터에서 리퍼 및 수리가 불가 할수도 있습니다.",
      "9. 액정을 열고 수리하는 경우 방수, 방진 기능이 저하됩니다.",
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

  static pw.Widget buildRepairAmountSection(
      String money,
      Map<String, bool> reviewOptions,
      bool hasNaverReservation,
      bool hasDiscount,
      pw.Font ttf) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      height: 80,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      '수리금액(원)',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.VerticalDivider(color: PdfColors.black, width: 1),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      money,
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              children: [
                _buildReviewRow(
                    '리뷰 참여',
                    ['네이버', '구글', '당근'],
                    [
                      reviewOptions['naver']!,
                      reviewOptions['google']!,
                      reviewOptions['daangn']!
                    ],
                    ttf),
                pw.Divider(color: PdfColors.black, height: 1),
                _buildReviewRow(
                    '네이버예약', ['네이버 예약'], [hasNaverReservation], ttf),
                pw.Divider(color: PdfColors.black, height: 1),
                _buildReviewRow('폰통령 할인', ['3,000원'], [hasDiscount], ttf),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReviewRow(
      String title, List<String> options, List<bool> boolOptions, pw.Font ttf) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: PdfColors.black),
                  right: pw.BorderSide(color: PdfColors.black),
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: options
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildCheckBox(
                        boolOptions[entry.key], entry.value, ttf),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
