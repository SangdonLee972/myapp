import 'dart:io';
import 'package:flutter/services.dart';
import 'package:myapp/model/used_phone_purchase.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class UsedPhonePdfGenerater {
  // 웹 환경 감지 함수 (static으로 변경)
  static bool isWeb() {
    try {
      // identical(0, 0.0)는 웹 환경에서 true를 반환
      return identical(0, 0.0);
    } catch (e) {
      return false; // 웹 환경이 아닐 경우 false 반환
    }
  }

  /// Generate a PDF matching the exact UI
  static Future<Uint8List> generateContract({
    required PurchaseAgreementModel agreement,
    Uint8List? signature,
  }) async {
    final pdf = pw.Document();
    // Load Korean font
    final fontData =
        await rootBundle.load('assets/font/NotoSansKR-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final logoImage = await rootBundle.load('assets/img/usedPhoneLogo.jpg');
    final fileName = 'contract_${DateTime.now().millisecondsSinceEpoch}.pdf';

    String formattedDate =
        '${agreement.saleDate.year}.${agreement.saleDate.month.toString().padLeft(2, '0')}.${agreement.saleDate.day.toString().padLeft(2, '0')}';
    // 스타일 정의
    final defaultTextStyle = pw.TextStyle(font: ttf, fontSize: 9);
    final boldTextStyle = pw.TextStyle(
      font: ttf,
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
    );
    final redTextStyle =
        pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.red);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 헤더 섹션
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  children: [
                    pw.Image(
                      pw.MemoryImage(logoImage.buffer.asUint8List()),
                      width: 80,
                      height: 80,
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '중고휴대기기 매매 계약서',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 19,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '판매하실 휴대기기의 매입거래를 정식적으로 인정하는 필수 서류입니다.',
                          style: defaultTextStyle,
                        ),
                        pw.Text(
                          '아래 내용을 정확하게 필독하신 후 고객님께 직접 작성해주세요.',
                          style: defaultTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // 판매자 정보 섹션
              _buildInfoRowTwo(
                  '매각일자', formattedDate, '매입 업체명', agreement.companyName, ttf),
              pw.SizedBox(height: 5),
              _buildInfoRowTwo('판매자명', agreement.sellerName, '판매자 생년월일',
                  agreement.birthdate, ttf),
              pw.SizedBox(height: 5),
              _buildInfoRow('판매자 연락처', agreement.contact, ttf),
              pw.SizedBox(height: 5),
              _buildInfoRowTwo('은행명', agreement.bankName, '예금주',
                  agreement.accountHolder, ttf),
              pw.SizedBox(height: 5),
              _buildInfoRow('계좌번호', agreement.accountNumber, ttf),
              pw.SizedBox(height: 5),
              _buildInfoRow('특이사항', agreement.remarks, ttf),

              pw.SizedBox(height: 16),

              // 명의자 확인 섹션
              _buildIsOwnerRow(
                agreement.nameHolder,
                agreement.nameHolderContact,
                agreement.relationship,
                agreement.isOwner,
                ttf,
              ),

              // 동의 항목 섹션
              _buildDetailedAgreementRow([
                pw.TextSpan(text: '※ 분실/도난 ', style: redTextStyle),
                pw.TextSpan(
                    text: '기기가 아님을 확인 후 매도하였으며, 추후에 ', style: defaultTextStyle),
                pw.TextSpan(text: '분실/도난 ', style: redTextStyle),
                pw.TextSpan(
                  text: '등의 사유로 문제가\n발생할 경우 민, 형사의 모든 책임을 지는 것에 대해 동의합니다.',
                  style: defaultTextStyle,
                ),
              ], agreement.isNotStolenOrLost, ttf),

              pw.SizedBox(height: 8),

              _buildDetailedAgreementRow([
                pw.TextSpan(text: '※ 정상적으로 해지된 ', style: defaultTextStyle),
                pw.TextSpan(text: '공기계 ', style: redTextStyle),
                pw.TextSpan(
                  text:
                      '상태임을 확인하였으며, 추후 타인 명의로 기기 등록 시 문제가 발생할 경우 환수 금액이 발생할 수 있음에 동의합니다.',
                  style: defaultTextStyle,
                ),
              ], agreement.isProperlyDeactivated, ttf),

              pw.SizedBox(height: 8),

              _buildDetailedAgreementRow([
                pw.TextSpan(text: '※ 매도 후 ', style: defaultTextStyle),
                pw.TextSpan(text: '단순변심 ', style: redTextStyle),
                pw.TextSpan(text: '및 기타 사유로 ', style: defaultTextStyle),
                pw.TextSpan(text: '거래 취소 및 환불 ', style: redTextStyle),
                pw.TextSpan(text: '이 불가능함을 동의합니다.', style: defaultTextStyle),
              ], agreement.noRefund, ttf),

              pw.SizedBox(height: 8),

              _buildDetailedAgreementRow([
                pw.TextSpan(text: '※ 매도 후 추후에', style: defaultTextStyle),
                pw.TextSpan(
                    text: ' 미납/연체/직권해지/AS 및 사설수리/암호잠김/침수 ',
                    style: redTextStyle),
                pw.TextSpan(
                    text: '등의 사유로 문제가 발생시 기기 및 기기 상태에 따라\n최소 1만원~100만원 상당의 금액이',
                    style: defaultTextStyle),
                pw.TextSpan(text: '매입가에서 환수', style: redTextStyle),
                pw.TextSpan(
                    text: '될 수 있음 과 이로 인한 민,형사상의 모든 책임을 지는 것에 동의합니다.',
                    style: defaultTextStyle),
              ], agreement.hasResponsibilityForIssues, ttf),

              pw.SizedBox(height: 16),

              // 서명 섹션
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '판매자 :',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    width: 70,
                    child: pw.Text(agreement.sellerName,
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
              ),

              pw.SizedBox(height: 16),

              // 기기 정보 테이블
              pw.TableHelper.fromTextArray(
                headers: ['No', '모델명', 'IMEI', '매입가격(원)'],
                data: agreement.devices
                    .asMap()
                    .entries
                    .map((entry) => [
                          entry.key + 1,
                          entry.value.modelName,
                          entry.value.imei,
                          entry.value.purchasePrice.toString(),
                        ])
                    .toList(),
                headerStyle: boldTextStyle,
                cellStyle: defaultTextStyle,
              ),
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
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return pdfData;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // **모바일(Android/iOS)**: 로컬 파일 저장
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/a.pdf';
      final file = File(filePath);

      await file.writeAsBytes(pdfData);

      return pdfData; // 저장된 파일 경로 반환
    } else {
      throw UnsupportedError('지원되지 않는 플랫폼입니다.');
    }
  }

  static pw.Widget _buildInfoRowTwo(
      String label1, String value1, String label2, String value2, pw.Font ttf) {
    return pw.Row(
      children: [
        // First field
        pw.Expanded(
          child: pw.Container(
            height: 40,
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 9),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  '$label1: ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  value1,
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10), // Spacing between the two containers
        // Second field
        pw.Expanded(
          child: pw.Container(
            height: 40,
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 9),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  '$label2: ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  value2,
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font ttf) {
    return pw.Container(
        height: 40,
        child: pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 9),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  '$label: ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  value,
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                ),
              ],
            ),
          ),
        ));
  }

  static pw.Widget _checkBox(bool isChecked, pw.Font ttf) {
    return pw.Container(
      width: 10,
      height: 10,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: isChecked
          ? pw.Center(
              child: pw.Text(
                '✓',
                style: pw.TextStyle(font: ttf, fontSize: 9),
              ),
            )
          : pw.Container(),
    );
  }

  static pw.Widget _buildIsOwnerRow(String? name, String? phone,
      String? relation, bool isChecked, pw.Font ttf) {
    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '※ 판매하신 기기가 ',
                style: pw.TextStyle(font: ttf, fontSize: 9),
              ),
              pw.TextSpan(
                text: '본인명의',
                style:
                    pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.red),
              ),
              pw.TextSpan(
                text: '가 맞습니까?',
                style: pw.TextStyle(font: ttf, fontSize: 9),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 30),
        pw.Text(
          '예 ',
          style: pw.TextStyle(font: ttf, fontSize: 8),
        ),
        _checkBox(isChecked, ttf),
        pw.SizedBox(width: 16),
        pw.Text(
          '아니요 ',
          style: pw.TextStyle(font: ttf, fontSize: 8),
        ),
        _checkBox(!isChecked, ttf)
      ]),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        pw.Text('         <본인 명의가 아닐 경우 작성>              명의자 이름 : ',
            style: pw.TextStyle(font: ttf, fontSize: 8)),
        pw.Container(
            width: 60,
            child: pw.Text(name ?? '',
                style: pw.TextStyle(font: ttf, fontSize: 8))),
        pw.Text('명의자 연락처 : ', style: pw.TextStyle(font: ttf, fontSize: 8)),
        pw.Container(
          width: 80,
          child:
              pw.Text(phone ?? '', style: pw.TextStyle(font: ttf, fontSize: 8)),
        ),
        pw.Text('관계 : ', style: pw.TextStyle(font: ttf, fontSize: 8)),
        pw.Text(relation ?? '', style: pw.TextStyle(font: ttf, fontSize: 10))
      ]),
      pw.SizedBox(height: 10),
    ]);
  }

  static pw.Widget _buildDetailedAgreementRow(
      List<pw.TextSpan> textSpans, bool isChecked, pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: textSpans,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Text(
              '동의함 ',
              style: pw.TextStyle(font: ttf, fontSize: 8),
            ),
            _checkBox(isChecked, ttf),
            pw.SizedBox(width: 16),
            pw.Text(
              '동의안함 ',
              style: pw.TextStyle(font: ttf, fontSize: 8),
            ),
            _checkBox(!isChecked, ttf)
          ],
        ),
      ],
    );
  }
}
