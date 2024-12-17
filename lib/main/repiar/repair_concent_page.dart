import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/main/repiar/repair_content_pdf_generater.dart';
import 'package:myapp/model/repair_concent.dart';
import 'package:signature/signature.dart';

class RepairConsentPage extends StatefulWidget {
  const RepairConsentPage({Key? key}) : super(key: key);

  @override
  State<RepairConsentPage> createState() => _RepairConsentPageState();
}

class _RepairConsentPageState extends State<RepairConsentPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController hasLoanPhoneController = TextEditingController();
  final TextEditingController otherInputController = TextEditingController();
  final TextEditingController issueDetailsController = TextEditingController();
  final TextEditingController repairAmountController = TextEditingController();

  // 서명 관련 함수
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _signatureImage;

  String customerName = "";

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    accountController.dispose();
    nameController.dispose();
    contactController.dispose();
    addressController.dispose();
    modelController.dispose();
    passwordController.dispose();
    hasLoanPhoneController.dispose();
    otherInputController.dispose();
    issueDetailsController.dispose();
    super.dispose();
  }

  // 고장증상
  final Map<String, bool> _issues = {
    // **** 고장 증상 **** //
    '액정파손': false,
    '액정불량': false,
    '카메라': false,
    '전원': false,
    '스피커': false,
    '배터리': false,
    '후면유리': false,
    '기타': false,
  };

  final Map<String, bool> _repairDetails = {
    "전원 불량": false,
    "화면 불량": false,
    "충전 불량": false,
    "터치 불량": false,
    "음성 불량": false,
    "카메라 불량": false,
    "홈 버튼 불량": false,
    "지문/Face ID 불량": false,
    "유심 인식 불량": false,
    "근접 불량": false,
    "발열 불량": false,
    "스피커 불량": false,
    "블루투스 불량": false,
    "송신음 불량": false,
    "배터리표시 불량": false,
    "신호검색 불량": false,
    "신호검색중": false,
    "와이파이 불량": false,
    "후면유리파손": false,
    "수리불가": false,
  };

  bool naver = false;
  bool google = false;
  bool daangn = false;
  bool naverBook = false;
  bool presidentPhoneSale = false;

  bool hasScreenDamage = false; // 액정파손 여부
  bool hasUsim = false; // 유심 보유 여부

  bool? _requiredConsent; // 필수 동의
  bool _selectiveConsent = false; // 선택 동의

  final Icon checkIcon = const Icon(
    Icons.check, // 빨간색 체크 아이콘
    color: Colors.red, // 빨간색 설정
    size: 20, // 아이콘 크기
  );

  void _validateAndSave() {
    List<String> missingFields = [];

    if (nameController.text.trim().isEmpty) missingFields.add("고객명");
    if (contactController.text.trim().isEmpty) missingFields.add("연락처");
    if (addressController.text.trim().isEmpty) missingFields.add("거주지역");
    if (modelController.text.trim().isEmpty) missingFields.add("기종");
    if (passwordController.text.trim().isEmpty) missingFields.add("기기 비밀번호");
    if (issueDetailsController.text.trim().isEmpty) {
      missingFields.add("고장 증상 세부내역");
    }
    if (repairAmountController.text.trim().isEmpty) missingFields.add("수리금액");

    // 수리 내용 체크박스 검증
    bool isAnyRepairDetailChecked = _repairDetails.values.contains(true);
    if (!isAnyRepairDetailChecked) {
      missingFields.add("수리 내용");
    }

    bool isAnyIssueChecked = _issues.values.contains(true);
    if (!isAnyIssueChecked) {
      missingFields.add("고장 증상");
    }

    // Check if signature is provided
    if (_signatureImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("서명을 완료해주세요"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${missingFields.join(", ")}을(를) 입력해주세요."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_requiredConsent != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("개인정보 수집 동의(필수)를 체크해주세요."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      saveConcent();
    }
  }

  void saveConcent() {
    // RepairRequestModel 객체 생성
    final repairRequest = RepairRequestModel(
      nameForStorage:
          "repair_${DateTime.now().millisecondsSinceEpoch}", // 저장용 이름
      customerName: nameController.text.trim(),
      contact: contactController.text.trim(),
      residence: addressController.text.trim(),
      deviceModel: modelController.text.trim(),
      devicePassword: passwordController.text.trim(),
      hasLoanPhone: hasLoanPhoneController.text.trim().isEmpty
          ? "" // 입력값이 없으면 빈 문자열
          : hasLoanPhoneController.text.trim().toLowerCase(), // 값이 'yes'면 true
      issueDetails: Map.from(_issues), // 고장 증상 Map
      repairDetails: Map.from(_repairDetails), // 수리 내용 Map
      isScreenDamaged: hasScreenDamage, // 액정 파손 여부
      hasSimCard: hasUsim, // 유심 여부
      detailedIssue: issueDetailsController.text.trim(),
      repairCost: double.tryParse(repairAmountController.text.trim()) ?? 0.0,
      reviewOptions: {
        'naver': naver,
        'google': google,
        'daangn': daangn
      }, // 리뷰 참여 옵션
      hasNaverReservation: naverBook, // 네이버 예약 여부
      hasDiscount: presidentPhoneSale, // 할인 여부
      requiredConsent: _requiredConsent!,
      selectiveConsent: _selectiveConsent,
      imageUrl: null, // 이미지 URL은 선택사항
    );

    RepairConsentPdfGenerator.generateConsentPdf(
        request: repairRequest, signature: _signatureImage);

    // 생성된 객체를 확인 (테스트용 출력)
    print("Repair Request Model Created: ${repairRequest.toMap()}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("수리의뢰서가 성공적으로 저장되었습니다!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.018;

    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('수리의뢰서'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    checkIcon,
                    const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
                    Text(
                      '필수 입력 부탁드립니다',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // 텍스트 색상
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Header Section
            Container(
              color: Colors.blue[100],
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '수리의뢰서',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize * 1.5, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '    계좌번호: 새마을 / 9003-2885-7867-0 / 장정현',
                  style: TextStyle(fontSize: fontSize * 1.1),
                ),
                Text(
                  '작성일 : $formattedDate',
                  style: TextStyle(fontSize: fontSize * 1.1),
                )
              ],
            ),
            const SizedBox(height: 4),

            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    _buildLabelCell('고객명', fontSize, true),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: nameController,
                        style: TextStyle(fontSize: fontSize),
                        decoration: InputDecoration(
                          hintText: '입력해주세요',
                          hintStyle: TextStyle(fontSize: fontSize * 0.9),
                          isDense: true, // 기본 패딩 제거
                          contentPadding: EdgeInsets.zero, // 내부 패딩 제거
                          border: InputBorder
                              .none, // 테두리 제거 // Compact height for the input field
                        ),
                        onChanged: (value) {
                          setState(() {
                            customerName = value; // 입력값 저장 및 UI 업데이트
                          });
                        },
                      ),
                    ),
                    _buildLabelCell('연락처', fontSize, true),
                    _buildInputCell(contactController, fontSize),
                  ],
                ),
              ],
            ),
            // Remaining Input Fields
            Table(
              border: const TableBorder(
                left: BorderSide(color: Colors.black, width: 1.0), // 왼쪽 선
                right: BorderSide(color: Colors.black, width: 1.0), // 오른쪽 선
                top: BorderSide.none, // 위쪽 선 제거
                bottom: BorderSide.none, // 아래쪽 선 제거
                horizontalInside:
                    BorderSide(color: Colors.black, width: 1.0), // 내부 수평선
                verticalInside:
                    BorderSide(color: Colors.black, width: 1.0), // 내부 수직선
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(5),
              },
              children: [
                _buildInputRow('거주지역/동', addressController, fontSize, true),
                _buildInputRow('기종', modelController, fontSize, true),
              ],
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    _buildLabelCell('기기 비밀번호', fontSize, true),
                    _buildInputCell(passwordController, fontSize),
                    _buildLabelCell('임대폰 여부', fontSize, false),
                    _buildInputCell(hasLoanPhoneController, fontSize),
                  ],
                ),
              ],
            ),
            Table(
              border: const TableBorder(
                left: BorderSide(color: Colors.black, width: 1.0), // 왼쪽 선
                right: BorderSide(color: Colors.black, width: 1.0), // 오른쪽 선
                top: BorderSide.none, // 위쪽 선 제거
                bottom: BorderSide.none, // 아래쪽 선 제거
                horizontalInside:
                    BorderSide(color: Colors.black, width: 1.0), // 내부 수평선
                verticalInside:
                    BorderSide(color: Colors.black, width: 1.0), // 내부 수직선
              ),
              columnWidths: const {
                0: FlexColumnWidth(1), // 왼쪽 1 비율
                1: FlexColumnWidth(5), // 오른쪽 5 비율
              },
              children: [
                TableRow(children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Text('고장증상',
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 6.0, // 항목 간의 가로 간격
                      runSpacing: 1.0, // 줄 간의 간격
                      children: _issues.keys.map((issue) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            newmakeCheckBox(issue),
                            Text(
                              issue,
                              style: TextStyle(fontSize: fontSize * 0.85),
                            ),
                            if (issue == '기타' &&
                                _issues[issue]!) // '기타'가 선택된 경우 TextField 표시
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: TextField(
                                    controller: otherInputController,
                                    style: TextStyle(fontSize: fontSize * 0.85),
                                    decoration: InputDecoration(
                                      hintText: '직접 입력',
                                      hintStyle:
                                          TextStyle(fontSize: fontSize * 0.85),
                                      isDense: true, // TextField 높이 조정
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0), // 텍스트 패딩
                                      border:
                                          const UnderlineInputBorder(), // 아래 선만 표시
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ]),
              ],
            ),

            Container(
              height: MediaQuery.of(context).size.height * 0.38, // 전체 높이의 절반
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // 양쪽 높이 동일하게 맞춤
                children: [
                  // 왼쪽 영역
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                        right: BorderSide(),
                                      )),
                                      child: Center(
                                        child: Text(
                                          '액정상태',
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildCheckboxRow('액정파손 있음',
                                            hasScreenDamage, fontSize, (value) {
                                          setState(() {
                                            hasScreenDamage = true;
                                          });
                                        }),
                                        _buildCheckboxRow(
                                            '액정파손 없음',
                                            !hasScreenDamage,
                                            fontSize, (value) {
                                          setState(() {
                                            hasScreenDamage = false;
                                          });
                                        }),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                        right: BorderSide(),
                                      )),
                                      child: Center(
                                        child: Text(
                                          '유심상태',
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildCheckboxRow(
                                            '유심칩 있음', hasUsim, fontSize,
                                            (value) {
                                          setState(() {
                                            hasUsim = true;
                                          });
                                        }),
                                        _buildCheckboxRow(
                                            '유심칩 없음', !hasUsim, fontSize,
                                            (value) {
                                          setState(() {
                                            hasUsim = false;
                                          });
                                        }),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          Expanded(
                              child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    right: BorderSide(),
                                  )),
                                  child: Center(
                                    child: Text(
                                      '고장증상\n세부내역',
                                      style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: issueDetailsController,
                                  style: TextStyle(
                                      fontSize:
                                          fontSize), // Apply font size to input text
                                  decoration: InputDecoration(
                                    isDense: true, // 기본 패딩 제거
                                    contentPadding:
                                        EdgeInsets.all(10), // 내부 패딩 제거
                                    border: InputBorder.none,
                                    hintText: '입력해주세요',
                                    hintStyle: TextStyle(
                                        fontSize: fontSize *
                                            0.9), // Hint text font size
                                  ),
                                ),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  // 오른쪽 영역
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                  border: Border(right: BorderSide())),
                              child: Center(
                                child: Text(
                                  '파손상태',
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: Image.asset(
                            'assets/img/phone.png',
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 248, 202, 180),
                  border: Border(right: BorderSide(), left: BorderSide())),
              child: Text(
                '*아래 사항은 작성하지 마세요*',
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                children: [
                  // 제목 영역
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        "수리 내용",
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    color: Colors.black,
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(left: BorderSide())),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Wrap(
                          spacing: 12.0, // 항목 간의 가로 간격
                          runSpacing: 8.0, // 줄 간의 간격
                          children: _repairDetails.keys.map((details) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                    scale: 0.7, // 크기를 조정
                                    child: Checkbox(
                                      value: _repairDetails[details],
                                      onChanged: (value) {
                                        setState(() {
                                          _repairDetails[details] = value!;
                                        });
                                      },
                                      side: const BorderSide(width: 1),
                                      // 체크박스 크기 조정
                                    )),
                                Text(
                                  details,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(), left: BorderSide())),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          '수리의뢰서',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.bold),
                        ),
                      )),
                  Expanded(
                      flex: 5,
                      child: Container(
                        decoration:
                            BoxDecoration(border: Border(left: BorderSide())),
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Center(
                          child: Text(
                            '(상위) 와 같은 증상으로 수리를 의뢰 합니다.',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ))
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        decoration:
                            BoxDecoration(border: Border(right: BorderSide())),
                        child: Center(
                          child: Text(
                            '수리금액(원)',
                            style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: repairAmountController,
                            style: TextStyle(
                                fontSize:
                                    fontSize), // Apply font size to input text
                            decoration: InputDecoration(
                              isDense: true, // 기본 패딩 제거
                              contentPadding: EdgeInsets.all(10), // 내부 패딩 제거
                              border: InputBorder.none,
                              hintText: '입력해주세요',
                              hintStyle: TextStyle(
                                  fontSize:
                                      fontSize * 0.9), // Hint text font size
                            ),
                          ))
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            decoration: const BoxDecoration(
                                border: Border(
                              left: BorderSide(),
                              right: BorderSide(),
                            )),
                            child: Center(
                              child: Text(
                                '리뷰 참여',
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                          )),
                          Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '네이버',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Transform.scale(
                                      scale: 0.7, // 크기를 조정
                                      child: Checkbox(
                                        value: naver,
                                        onChanged: (value) {
                                          setState(() {
                                            naver = value!;
                                          });
                                        },
                                        side: const BorderSide(width: 1),
                                        // 체크박스 크기 조정
                                      )),
                                  Text(
                                    '구글',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Transform.scale(
                                      scale: 0.7, // 크기를 조정
                                      child: Checkbox(
                                        value: google,
                                        onChanged: (value) {
                                          setState(() {
                                            google = value!;
                                          });
                                        },
                                        side: const BorderSide(width: 1),
                                        // 체크박스 크기 조정
                                      )),
                                  Text(
                                    '당근',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Transform.scale(
                                      scale: 0.7, // 크기를 조정
                                      child: Checkbox(
                                        value: daangn,
                                        onChanged: (value) {
                                          setState(() {
                                            daangn = value!;
                                          });
                                        },
                                        side: const BorderSide(width: 1),
                                        // 체크박스 크기 조정
                                      )),
                                ],
                              )),
                        ],
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.black,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    left: BorderSide(),
                                    right: BorderSide(),
                                  )),
                                  child: Center(
                                    child: Text(
                                      '네이버예약',
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  ))),
                          Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '네이버 예약',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Transform.scale(
                                      scale: 0.7, // 크기를 조정
                                      child: Checkbox(
                                        value: naverBook,
                                        onChanged: (value) {
                                          setState(() {
                                            naverBook = value!;
                                          });
                                        },
                                        side: const BorderSide(width: 1),
                                        // 체크박스 크기 조정
                                      )),
                                ],
                              )),
                        ],
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.black,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    left: BorderSide(),
                                    right: BorderSide(),
                                  )),
                                  child: Center(
                                    child: Text(
                                      '폰통령 할인',
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  ))),
                          Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '3,000원',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Transform.scale(
                                      scale: 0.7, // 크기를 조정
                                      child: Checkbox(
                                        value: presidentPhoneSale,
                                        onChanged: (value) {
                                          setState(() {
                                            presidentPhoneSale = value!;
                                          });
                                        },
                                        side: const BorderSide(width: 1),
                                        // 체크박스 크기 조정
                                      )),
                                ],
                              )),
                        ],
                      )
                    ],
                  ))
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes Section
            Align(
              alignment: Alignment.center,
              child: Text(
                '< 수리 의뢰 시 주의사항 >',
                style: TextStyle(
                    fontSize: fontSize * 1.15, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '1. 외부 충격이나 침수에 의한 고장 수리의 경우,\n'
              '회로의 이상 오작동으로 전원 불량이 발생하여 수리를 할 수 없는 경우가 발생할 수 있습니다.\n'
              '2. 메인보드 수리 도중 데이터 유실 및 기타 이상 증상이 발생할 수 있습니다. 이에 대한 당사의 책임이 없음을 공지 드립니다.\n'
              '3. 기기의 비밀번호를 적어주시기 바랍니다. 수리 후 기기 점검을 위해 필요합니다.\n'
              '4. 액정, 카메라, 배터리 등 부품 교체의 경우 교체 메시지가 보일 수 있습니다.\n'
              '5. 후면 유리 수리 경우, 충격 여부에 따라 메인보드 및 기타 이상 증상 있을수 있습니다.(추가비용발생합니다.)\n'
              '6. 모든 수리는 수리 완료 후 입금해주시는 건에 대해 당일 출고가 진행됩니다.\n'
              '7. 수리 후 보증기간은 6개월입니다.(단 고객과실 시 유상수리 진행)\n'
              '8. 수리 후 정식센터에서 리퍼 및 수리가 불가 할수도 있습니다.\n'
              '9. 액정을 열고 수리하는 경우 방수, 방진 기능이 저하됩니다.',
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(height: 5),

            //requiredConsent
            Text(
              '개인정보 수집동의(필수)',
              style: TextStyle(
                  fontSize: fontSize * 1.05, fontWeight: FontWeight.bold),
            ),
            Text(
              '본 수리센터의 이벤트 참여 등을 위해 아래와 같이 개인정보를 수집.이용합니다.\n'
              '수집목적 - 이벤트 안내 / 수집항목 - 성명, 전화번호 / 보유기간 - 3년',
              style: TextStyle(fontSize: fontSize),
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Checkbox(
                    value: _requiredConsent ?? false,
                    onChanged: (value) {
                      setState(() {
                        _requiredConsent = true;
                      });
                    },
                    side: const BorderSide(width: 1),
                  ),
                ),
                Text(
                  '동의함',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.7,
                  child: Checkbox(
                    value: _requiredConsent != null
                        ? _requiredConsent == false
                        : false,
                    onChanged: (value) {
                      setState(() {
                        _requiredConsent = false;
                      });
                    },
                    side: const BorderSide(width: 1),
                  ),
                ),
                Text(
                  '동의 안함',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),

            // Selection Concent
            const SizedBox(height: 5),
            Text(
              '이벤트 활용 동의 및 광고 수신 동의(선택)',
              style: TextStyle(
                  fontSize: fontSize * 1.05, fontWeight: FontWeight.bold),
            ),
            Text(
              '수리 안내 및 이벤트 공지(ex. 배터리 무료 교체) 등 다양한 정보를 제공합니다.',
              style: TextStyle(fontSize: fontSize),
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.7, // 크기를 조정
                  child: Checkbox(
                    value: _selectiveConsent, // null일 경우 기본값 false 설정
                    onChanged: (value) {
                      setState(() {
                        _selectiveConsent = value!; // null 체크 필요 없이 바로 값 설정
                      });
                    },
                    side: const BorderSide(width: 1),
                  ),
                ),
                Text(
                  'SMS, SNS 수신동의 (선택)',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
            // Signature Section
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                '이름   :   ',
                style: TextStyle(
                    fontSize: fontSize * 1.6, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: screenWidth * 0.16,
                child: Text(
                  customerName,
                  style: TextStyle(
                      fontSize: fontSize * 1.6, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: _showSignaturePad, // 서명 패드 표시
                child: Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color.fromARGB(69, 0, 0, 0)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 서명 이미지 (입력 후 표시)
                      if (_signatureImage != null)
                        Image.memory(
                          _signatureImage!,
                          fit: BoxFit.contain,
                        ),

                      const Text(
                        '[서명]',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(96, 117, 117, 117),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _validateAndSave();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 187, 131, 224), // 버튼 배경색
                    foregroundColor:
                        const Color.fromARGB(255, 255, 255, 255), // 텍스트 색상
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0), // 패딩 조정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // 둥근 모서리
                    ),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.08,
                    child: Center(
                      child: Text(
                        '동의서 저장',
                        style: TextStyle(
                            fontSize: fontSize * 1.6,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Builds a table row with a label and a text input field
  TableRow _buildInputRow(String label, TextEditingController controller,
      double fontSize, bool isRequired) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRequired) // 필수 여부에 따라 체크 아이콘 표시
                Icon(
                  Icons.check,
                  color: Colors.red,
                  size: fontSize,
                ),
              if (isRequired) const SizedBox(width: 4),
              Text(
                label,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: controller,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '입력해주세요',
              hintStyle: TextStyle(fontSize: fontSize * 0.9),
            ),
          ),
        ),
      ],
    );
  }

  // Builds a label cell for TableRow
  Widget _buildLabelCell(String label, double fontSize, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRequired) // 필수 여부에 따라 체크 아이콘 표시
            Icon(
              Icons.check,
              color: Colors.red, // 체크 아이콘 색상
              size: fontSize, // 아이콘 크기
            ),
          if (isRequired) const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds an input cell for TableRow
  Widget _buildInputCell(TextEditingController controller, double fontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: '입력해주세요',
          hintStyle: TextStyle(fontSize: fontSize * 0.9),
          isDense: true, // 기본 패딩 제거
          contentPadding: EdgeInsets.zero, // 내부 패딩 제거
          border:
              InputBorder.none, // 테두리 제거 // Compact height for the input field
        ),
      ),
    );
  }

  Widget newmakeCheckBox(issue) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0),
      child: SizedBox(
        width: 16.0, // 원하는 너비로 설정
        height: 16.0, // 원하는 높이로 설정
        child: Transform.scale(
          scale: 0.7, // 체크박스 크기 조정
          child: Checkbox(
            value: _issues[issue],
            onChanged: (value) {
              setState(() {
                _issues[issue] = value!;
              });
            },
            side: const BorderSide(width: 1),
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
            visualDensity: VisualDensity.compact, // 시각적 밀도 조정
          ),
        ),
      ),
    );
  }

  // 체크박스 Row
  Widget _buildCheckboxRow(
      String label, bool value, double fontSize, Function(bool?) onChanged) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.7, // 체크박스 크기 조정
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            side: const BorderSide(width: 1),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  // 서명 관련 함수

  void _showSignaturePad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 화면 높이에 따라 동적 크기 조정
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // 키보드 등 화면 크기 조정
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  '서명을 입력해주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      child: const Text('지우기'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_signatureController.isNotEmpty) {
                          // 서명을 이미지로 변환
                          final signature =
                              await _signatureController.toPngBytes();
                          if (signature != null) {
                            setState(() {
                              _signatureImage = signature; // 서명 이미지 저장
                            });
                          }
                        }
                        Navigator.of(context).pop(); // BottomSheet 닫기
                      },
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
