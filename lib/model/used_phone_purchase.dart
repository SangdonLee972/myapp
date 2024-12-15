// lib/models/purchase_agreement_model.dart
class PurchaseAgreementModel {
  // 계약서 모델 중심 정보
  final String nameForStorage; // 저장 시 사용되는 이름
  final DateTime saleDate; // 매각일자
  final String companyName; // 매각 업체명
  final String sellerName; // 판매자명
  final String contact; // 판매자 연락처
  final String birthdate; // 판매자 생년월일
  final String bankName; // 은행명
  final String accountHolder; // 예금주
  final String accountNumber; // 계좌번호
  final String remarks; // 특이사항

  // 본인 명의 여부 및 동의 사항
  final bool isOwner; // 본인 명의 여부
  final String? nameHolder; // 명의자 이름 (본인 명의가 아닌 경우)
  final String? nameHolderContact; // 명의자 연락처 (본인 명의가 아닌 경우)
  final String? relationship; // 명의자와의 관계 (본인 명의가 아닌 경우)
  
  final bool isNotStolenOrLost; // 분실/도난 여부
  final bool isProperlyDeactivated; // 정상 해지 여부
  final bool noRefund; // 단순 변심 환불 불가 여부
  final bool hasResponsibilityForIssues; // 문제 발생 시 책임 여부

  // 기기 정보 및 서명 이미지
  final List<Device> devices; // 기기 리스트
  final String? imageUrl; // 서명 이미지 URL (선택)

  PurchaseAgreementModel({
    required this.nameForStorage,
    required this.saleDate,
    required this.companyName,
    required this.sellerName,
    required this.contact,
    required this.birthdate,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.remarks,
    required this.isOwner,
    this.nameHolder,
    this.nameHolderContact,
    this.relationship,
    required this.isNotStolenOrLost,
    required this.isProperlyDeactivated,
    required this.noRefund,
    required this.hasResponsibilityForIssues,
    required this.devices,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nameForStorage': nameForStorage,
      'saleDate': saleDate.toIso8601String(),
      'companyName': companyName, // Added field
      'sellerName': sellerName,
      'contact': contact,
      'birthdate': birthdate,
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'remarks': remarks,
      'isOwner': isOwner,
      'nameHolder': nameHolder,
      'nameHolderContact': nameHolderContact,
      'relationship': relationship,
      'isNotStolenOrLost': isNotStolenOrLost,
      'isProperlyDeactivated': isProperlyDeactivated,
      'noRefund': noRefund,
      'hasResponsibilityForIssues': hasResponsibilityForIssues,
      'devices': devices.map((device) => device.toMap()).toList(),
      'imageUrl': imageUrl,
    };
  }
}


// 판매 기기 모델
class Device {
  final String modelName;
  final String imei;
  final double purchasePrice;

  Device({
    required this.modelName,
    required this.imei,
    required this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'modelName': modelName,
      'imei': imei,
      'purchasePrice': purchasePrice,
    };
  }
}
