import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myapp/auth/service/save_service.dart';
import 'package:myapp/main/phonePurchase/used_phone_pdf_generater.dart';
import 'package:myapp/model/used_phone_purchase.dart';
import 'package:signature/signature.dart';

class UsedPhonePurchasePage extends StatefulWidget {
  @override
  State<UsedPhonePurchasePage> createState() => _UsedPhonePurchasePageState();
}

class _UsedPhonePurchasePageState extends State<UsedPhonePurchasePage> {
  // TextEditingControllers for inputs
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _sellerBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // 본인명의가 아닐경우
  final TextEditingController _nameHolderController =
      TextEditingController(); // 명의자 이름
  final TextEditingController _nameHolderContactController =
      TextEditingController(); // 명의자 연락처
  final TextEditingController _relationshipController =
      TextEditingController(); // 관계

  // 서명 관련 변수
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Uint8List? _signatureImage; // 서명 이미지를 저장할 변수

  // Device details as a list of rows
  final List<Map<String, String>> _deviceDetails = [
    {'modelName': '', 'imei': '', 'price': ''}
  ];

  String sellerName = '';
  // Checkbox values
  bool? _isOwner;
  bool? _agreement1;
  bool? _agreement2;
  bool? _agreement3;
  bool? _agreement4;

  // 판매 기기 관련 삭제 추가 함수
  void _addDeviceRow() {
    setState(() {
      _deviceDetails.add({'modelName': '', 'imei': '', 'price': ''});
    });
  }

  void _deleteDeviceRow() {
    if (_deviceDetails.length > 1) {
      setState(() {
        _deviceDetails.removeAt(_deviceDetails.length - 1);
      });
    }
  }

  // 입력 잘 했는지 검사하는 함수
  void _canSaveCheck() {
    // Check for missing inputs
    if (_dateController.text.isEmpty) {
      _showError('매각일자를 입력해주세요.');
      return;
    }
    if (_companyController.text.isEmpty) {
      _showError('매입 업체명을 입력해주세요.');
      return;
    }
    if (_sellerNameController.text.isEmpty) {
      _showError('판매자명을 입력해주세요.');
      return;
    }
    if (_sellerBirthController.text.isEmpty) {
      _showError('판매자 생년월일을 입력해주세요.');
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showError('판매자 연락처를 입력해주세요.');
      return;
    }
    if (_bankNameController.text.isEmpty) {
      _showError('은행명을 입력해주세요.');
      return;
    }
    if (_accountHolderController.text.isEmpty) {
      _showError('예금주명을 입력해주세요.');
      return;
    }
    if (_accountNumberController.text.isEmpty) {
      _showError('계좌번호를 입력해주세요.');
      return;
    }

    if (_isOwner == null) {
      _showError('본인명의 여부를 선택해주세요.');
      return;
    }

    // If "본인 명의가 아님"을 선택했을 때 추가 필드 검사
    if (_isOwner == false) {
      if (_nameHolderController.text.isEmpty) {
        _showError('명의자 이름을 입력해주세요.');
        return;
      }
      if (_nameHolderContactController.text.isEmpty) {
        _showError('명의자 연락처를 입력해주세요.');
        return;
      }
      if (_relationshipController.text.isEmpty) {
        _showError('명의자와의 관계를 입력해주세요.');
        return;
      }
    }

    // Check for agreement checks
    if (_agreement1 != true) {
      _showError('동의사항 1에 동의해주세요.');
      return;
    }
    if (_agreement2 != true) {
      _showError('동의사항 2에 동의해주세요.');
      return;
    }
    if (_agreement3 != true) {
      _showError('동의사항 3에 동의해주세요.');
      return;
    }
    if (_agreement4 != true) {
      _showError('동의사항 4에 동의해주세요.');
      return;
    }

    // Check if there is at least one device row
    if (_deviceDetails.isEmpty ||
        _deviceDetails.firstWhere((device) {
          return device['modelName']!.isEmpty ||
              device['imei']!.isEmpty ||
              device['price']!.isEmpty;
        }, orElse: () => {}).isNotEmpty) {
      _showError('판매 기기 정보가 올바르게 입력되지 않았습니다.');
      return;
    }

    // Check if signature is provided
    if (_signatureImage == null) {
      _showError('서명을 완료해주세요.');
      return;
    }

    // If all checks pass, proceed with saving
    _proceedWithSaving();
  }

// 저장 처리 함수
  void _proceedWithSaving() async {
    try {
      String? agreementName = await _showNameInputDialog(context);
      if (agreementName == null || agreementName.isEmpty) {
        _showError('이름을 입력해야 합니다.');
        return;
      }

      // Step 1: 기기 정보 리스트 생성
      final devices = _deviceDetails.map((device) {
        return Device(
          modelName: device['modelName'] ?? '',
          imei: device['imei'] ?? '',
          purchasePrice: double.tryParse(device['price'] ?? '0') ?? 0,
        );
      }).toList();

      // Step 2: PurchaseAgreementModel 객체 생성
      final purchaseAgreement = PurchaseAgreementModel(
        nameForStorage: agreementName, // 예: "홍길동_2023-12-07"
        saleDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
        companyName: _companyController.text,
        sellerName: _sellerNameController.text,
        contact: _phoneController.text,
        birthdate: _sellerBirthController.text,
        bankName: _bankNameController.text,
        accountHolder: _accountHolderController.text,
        accountNumber: _accountNumberController.text,
        remarks: _notesController.text,
        isOwner: _isOwner ?? true,
        nameHolder: _isOwner == false ? _nameHolderController.text : null,
        nameHolderContact:
            _isOwner == false ? _nameHolderContactController.text : null,
        relationship: _isOwner == false ? _relationshipController.text : null,
        isNotStolenOrLost: _agreement1 ?? false,
        isProperlyDeactivated: _agreement2 ?? false,
        noRefund: _agreement3 ?? false,
        hasResponsibilityForIssues: _agreement4 ?? false,
        devices: devices,
      );

      // Step 3: PDF 생성
      Uint8List pdfData = (await UsedPhonePdfGenerater.generateContract(
        agreement: purchaseAgreement,
        signature: _signatureImage,
      )) as Uint8List;
      print('testset');

      // Step 4: Firebase 저장 로직 호출
      await SaveService.savePurchaseAgreement(
        agreement: purchaseAgreement,
        pdfData: pdfData,
        signatureImage: _signatureImage,
      );

      print('upload Success');

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('계약서가 성공적으로 저장되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 에러 처리
      print('Error while saving agreement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 에러 출력 함수
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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

  // 팝업창 함수
  Future<String?> _showNameInputDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이름 입력'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: '동의서에 작성할 이름을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text.trim());
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is destroyed
    _dateController.dispose();
    _companyController.dispose();
    _sellerNameController.dispose();
    _sellerBirthController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _notesController.dispose();

    _nameHolderController.dispose();
    _nameHolderContactController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.018;

    return Scaffold(
      appBar: AppBar(
        title: Text('중고휴대기기 매매 계약서'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                children: [
                  Image.asset('assets/img/usedPhoneLogo.jpg',
                      width: screenWidth * 0.18),
                  SizedBox(width: screenWidth * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '중고휴대기기 매매 계약서',
                        style: TextStyle(
                            fontSize: fontSize * 2,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '판매하실 휴대기기의 매입거래를 정식적으로 인정하는 필수 서류입니다.',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      Text(
                        '아래 내용을 정확하게 필독하신 후 고객님께 직접 작성해주세요.',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 매각일자 및 기타 정보
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: '매각일자',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: '매입 업체명',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sellerNameController,
                    decoration: InputDecoration(
                      labelText: '판매자명',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        sellerName = value; // sellerName 변수에 실시간 반영
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _sellerBirthController,
                    decoration: InputDecoration(
                      labelText: '판매자 생년월일(앞 6자리)',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '판매자 연락처',
                labelStyle: TextStyle(fontSize: fontSize),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: '은행명',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _accountHolderController,
                    decoration: InputDecoration(
                      labelText: '예금주',
                      labelStyle: TextStyle(fontSize: fontSize),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                labelText: '계좌번호',
                labelStyle: TextStyle(fontSize: fontSize),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 특이사항
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: '특이사항',
                labelStyle: TextStyle(fontSize: fontSize),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 소유권 확인
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: '※ 판매하신 기기가 ',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                    children: [
                      TextSpan(
                        text: '본인 명의',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize),
                      ),
                      TextSpan(
                        text: '가 맞습니까?',
                        style:
                            TextStyle(color: Colors.black, fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _isOwner ?? false,
                    onChanged: (value) {
                      setState(() {
                        _isOwner = true;
                      });
                    },
                  ),
                ),
                Text(
                  '예',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _isOwner != null ? _isOwner == false : false,
                    onChanged: (value) {
                      setState(() {
                        _isOwner = false;
                      });
                    },
                  ),
                ),
                Text(
                  '아니오',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
            if (_isOwner == false)
              const SizedBox(
                height: 16,
              ),
            if (_isOwner == false)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameHolderController,
                      decoration: InputDecoration(
                        labelText: '명의자 이름',
                        labelStyle: TextStyle(fontSize: fontSize),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _nameHolderContactController,
                      decoration: InputDecoration(
                        labelText: '명의자 연락',
                        labelStyle: TextStyle(fontSize: fontSize),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _relationshipController,
                      decoration: InputDecoration(
                        labelText: '관계',
                        labelStyle: TextStyle(fontSize: fontSize),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(
              height: 16,
            ),

            // 동의사항 1
            RichText(
              text: TextSpan(
                text: '※',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                children: [
                  TextSpan(
                    text: ' 분실/도난',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  TextSpan(
                    text: ' 기기가 아님을 확인 후 매도하였으며, 추후에 ',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                  TextSpan(
                    text: '분실/도난',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: ' 등의 사유로 문제',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            ),
            Text(
              '발생 할 경우 민,형사의 모든 책임을 지는 것에 대해 동의 합니다.',
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement1 ?? false,
                    onChanged: (value) {
                      setState(() {
                        _agreement1 = true;
                      });
                    },
                  ),
                ),
                Text(
                  '동의함',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement1 != null ? _agreement1 == false : false,
                    onChanged: (value) {
                      setState(() {
                        _agreement1 = false;
                      });
                    },
                  ),
                ),
                Text(
                  '동의안함',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),
            // 동의사항 2
            RichText(
              text: TextSpan(
                text: '※ 정상적으로 해지된',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                children: [
                  TextSpan(
                    text: ' 공기계 ',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: '상태임을 확인하였으며, 추후에 타인명의로 기기 등록 시 문제가 발생 할 경우',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            ),
            Text(
              '이로 인해 환수금액이 발생 할 수 있음에 동의합니다.',
              style: TextStyle(fontSize: fontSize),
            ),

            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement2 ?? false,
                    onChanged: (value) {
                      setState(() {
                        _agreement2 = true;
                      });
                    },
                  ),
                ),
                Text(
                  '동의함',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement2 != null ? _agreement2 == false : false,
                    onChanged: (value) {
                      setState(() {
                        _agreement2 = false;
                      });
                    },
                  ),
                ),
                Text(
                  '동의안함',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),
            // 동의사항 3
            RichText(
              text: TextSpan(
                text: '※ ',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                children: [
                  TextSpan(
                    text: '매도 후 단순변심',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: ' 및 기타사유로 ',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                  TextSpan(
                    text: '거래취소 및 환불',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: '이 되어 질수 없음에 동의합니다.',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement3 ?? false,
                    onChanged: (value) {
                      setState(() {
                        _agreement3 = true;
                      });
                    },
                  ),
                ),
                Text(
                  '동의함',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement3 != null ? _agreement3 == false : false,
                    onChanged: (value) {
                      setState(() {
                        _agreement3 = false;
                      });
                    },
                  ),
                ),
                Text(
                  '동의안함',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),
            // 동의사항 4
            RichText(
              text: TextSpan(
                text: '※ 매도 후 추후에 ',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                children: [
                  TextSpan(
                    text: '미납/연체/직권해지/AS 및 사설수리/암호잠김/침수',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: ' 등의 사유로 문제가 발생시 기기 및 기기 상태에 따라',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: '최소 1만원~100만원 상당의 금액이 ',
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                children: [
                  TextSpan(
                    text: '매입가에서 환수 ',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize),
                  ),
                  TextSpan(
                    text: '될 수 있음 과 이로 인한 민,형사상의 모든 책임을 지는 것에 동의합니다.',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement4 ?? false,
                    onChanged: (value) {
                      setState(() {
                        _agreement4 = true;
                      });
                    },
                  ),
                ),
                Text(
                  '동의함',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 30),
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: _agreement4 != null ? _agreement4 == false : false,
                    onChanged: (value) {
                      setState(() {
                        _agreement4 = false;
                      });
                    },
                  ),
                ),
                Text(
                  '동의안함',
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),

            //서명 란
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                '판매자   :   ',
                style: TextStyle(
                    fontSize: fontSize * 1.6, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: screenWidth * 0.16,
                child: Text(
                  sellerName,
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

            // 판매 기기 정보
            const Text('판매 기기 정보'),
            const SizedBox(height: 8),
            SizedBox(
              width: screenWidth * 0.7,
              child: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FractionColumnWidth(0.1),
                  1: FractionColumnWidth(0.38),
                  2: FractionColumnWidth(0.3),
                  3: FractionColumnWidth(0.22),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSize * 1.25),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '모델명',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSize * 1.25),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'IMEI',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSize * 1.25),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '매입가격(원)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSize * 1.25),
                        ),
                      ),
                    ],
                  ),
                  ..._deviceDetails.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final device = entry.value;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(fontSize: fontSize * 1.25),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              style: TextStyle(fontSize: fontSize * 1.2),
                              onChanged: (value) => device['modelName'] = value,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              style: TextStyle(fontSize: fontSize * 1.2),
                              onChanged: (value) => device['imei'] = value,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true, // 패딩 제거
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              style: TextStyle(fontSize: fontSize * 1.2),
                              onChanged: (value) => device['price'] = value,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // 판매 기기 추가 삭제 버튼
            Row(
              children: [
                TextButton(
                  onPressed: _addDeviceRow,
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
                  child: const Text('기기 추가'),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: _deleteDeviceRow,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 111, 108, 112), // 버튼 배경색
                    foregroundColor:
                        const Color.fromARGB(255, 255, 255, 255), // 텍스트 색상
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0), // 패딩 조정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // 둥근 모서리
                    ),
                  ),
                  child: const Text('기기 삭제'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _canSaveCheck,
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
                        '계약서 저장',
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
}
