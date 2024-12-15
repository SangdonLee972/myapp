// lib/models/repair_request_model.dart
class RepairRequestModel {
  //!! ( 아래변수 저장하기 눌럿을때 검색 통해 나오는 부분이야 계약서 중심이 되는 이름)
  final String nameForStorage; // 저장 시 사용되는 이름
  final String customerName; // 고객명
  final String contact; // 연락처
  final String residence; // 거주지역/동
  final String deviceModel; // 기종
  final String devicePassword; // 기기 비밀번호
  final bool hasLoanPhone; // 임대폰 여부
  final String issueDescription; // 고장 증상
  final bool isScreenDamaged; // 액정 파손 여부
  final bool hasSimCard; // 유심 있음 여부
  final String detailedIssue; // 고장 증상 세부내역
  final String repairDetails; // 수리 내용
  final double repairCost; // 수리 금액
  final String reviewOption; // 리뷰 참여 (네이버, 구글, 당근)
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
    required this.issueDescription,
    required this.isScreenDamaged,
    required this.hasSimCard,
    required this.detailedIssue,
    required this.repairDetails,
    required this.repairCost,
    required this.reviewOption,
    required this.hasNaverReservation,
    required this.hasDiscount,
    required this.nameForStorage,
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
      'issueDescription': issueDescription,
      'isScreenDamaged': isScreenDamaged,
      'hasSimCard': hasSimCard,
      'detailedIssue': detailedIssue,
      'repairDetails': repairDetails,
      'repairCost': repairCost,
      'reviewOption': reviewOption,
      'hasNaverReservation': hasNaverReservation,
      'hasDiscount': hasDiscount,
      'nameForStorage': nameForStorage,
      'imageUrl': imageUrl,
    };
  }
}
