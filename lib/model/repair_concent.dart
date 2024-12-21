class RepairRequestModel {
  // 저장 시 사용되는 이름
  final String nameForStorage; // 계약서 이름 중심
  final String customerName; // 고객명
  final String contact; // 연락처
  final String residence; // 거주지역/동
  final String deviceModel; // 기종
  final String devicePassword; // 기기 비밀번호
  final String hasLoanPhone; // 임대폰 여부

  // 고장 증상과 수리 내용
  final Map<String, bool> issueDetails; // 고장 증상 (액정파손, 배터리 등)
  final String otherIssueDetail;
  final Map<String, bool> repairDetails; // 수리 내용 (전원 불량, 화면 불량 등)

  final bool isScreenDamaged; // 액정 파손 여부
  final bool hasSimCard; // 유심 있음 여부
  final String detailedIssue; // 고장 증상 세부내역
  final String repairCost; // 수리 금액
  final bool requiredConsent;
  final bool selectiveConsent;

  // 추가 옵션
  final Map<String, bool> reviewOptions; // 리뷰 참여 (네이버, 구글, 당근)
  final bool hasNaverReservation; // 네이버 예약 여부
  final bool hasDiscount; // 폰통령 할인 여부

  final String? imageUrl; // 사진 URL (선택)

  RepairRequestModel({
    required this.customerName,
    required this.contact,
    required this.residence,
    required this.deviceModel,
    required this.devicePassword,
    required this.hasLoanPhone,
    required this.issueDetails, // 고장 증상 Map
    required this.otherIssueDetail,
    required this.repairDetails, // 수리 내용 Map
    required this.isScreenDamaged,
    required this.hasSimCard,
    required this.detailedIssue,
    required this.repairCost,
    required this.reviewOptions,
    required this.hasNaverReservation,
    required this.hasDiscount,
    required this.nameForStorage,
    required this.requiredConsent, // 필수 동의
    required this.selectiveConsent, // 선택 동의
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'contact': contact,
      'residence': residence,
      'deviceModel': deviceModel,
      'devicePassword': devicePassword,
      'hasLoanPhone': hasLoanPhone,
      'issueDetails': issueDetails, // 고장 증상 Map
      'otherIssueDetail': otherIssueDetail,
      'repairDetails': repairDetails, // 수리 내용 Map
      'isScreenDamaged': isScreenDamaged,
      'hasSimCard': hasSimCard,
      'detailedIssue': detailedIssue,
      'repairCost': repairCost,
      'reviewOptions': reviewOptions,
      'hasNaverReservation': hasNaverReservation,
      'hasDiscount': hasDiscount,
      'nameForStorage': nameForStorage,
      'requiredConsent': requiredConsent,
      'selectiveConsent': selectiveConsent,
      'imageUrl': imageUrl,
    };
  }
}
