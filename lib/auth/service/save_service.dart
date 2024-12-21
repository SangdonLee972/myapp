import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/model/repair_concent.dart';
import 'package:myapp/model/used_phone_purchase.dart';
import 'dart:typed_data';

class SaveService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  /// Firebase Storage에 파일 업로드
  static Future<String> uploadFile(Uint8List fileData, String fileName) async {
    try {
      final storageRef = _storage.ref('agreements/$fileName');
      await storageRef.putData(fileData);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return 'failURl';
    }
  }

  /// Firestore에 계약서 데이터 저장
  static Future<void> savePurchaseAgreement({
    required PurchaseAgreementModel agreement,
    required Uint8List pdfData,
    Uint8List? signatureImage,
  }) async {
    try {
      // 1. PDF 파일 업로드
      final pdfFileName = '${agreement.nameForStorage}.pdf';
      final pdfUrl = await uploadFile(pdfData, pdfFileName);
      print(pdfUrl);

      // 2. 서명 이미지 업로드 (선택)
      String? signatureImageUrl;
      if (signatureImage != null) {
        final signatureFileName = '${agreement.nameForStorage}-signature.png';
        signatureImageUrl = await uploadFile(signatureImage, signatureFileName);
      }

      // 3. Firestore에 데이터 저장
      final agreementData = agreement.toMap();
      agreementData['pdfUrl'] = pdfUrl;
      agreementData['imageUrl'] = signatureImageUrl;
      agreementData['createdAt'] = FieldValue.serverTimestamp(); // 생성 시간 추가

      await _firestore.collection('purchaseAgreements').add(agreementData);
    } catch (e) {
      print('Error saving purchase agreement: $e');
      throw Exception('Failed to save purchase agreement');
    }
  }

  static Future<List<Map<String, dynamic>>> getRepairRecords() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('repairAgreements') // 컬렉션 이름 일치
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'customerName': data['customerName'] ?? '',
          'contact': data['contact'] ?? '',
          'deviceModel': data['deviceModel'] ?? '',
          'residence': data['residence'] ?? '',
          'devicePassword': data['devicePassword'] ?? '',
          'issueDetails': Map<String, bool>.from(data['issueDetails'] ?? {}),
          'repairDetails': Map<String, bool>.from(data['repairDetails'] ?? {}),
          'repairCost': data['repairCost'] ?? '',
                  'selectiveConsent': data['selectiveConsent'] == true
            ? '동의'
            : '비동의', // selectiveConsent를 '동의' 또는 '비동의'로 변환
        };
      }).toList();
    } catch (e) {
      print('Error fetching repair records: $e');
      throw Exception('Failed to fetch repair records');
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedRecords() async {
    try {
      // Firestore의 'purchaseAgreements' 컬렉션에서 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('purchaseAgreements') // 컬렉션 이름 일치
          .get();

      // 데이터를 변환하여 리스트에 담기
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['sellerName'] ?? '', // 판매자 이름
          'imei': data['devices'] != null && data['devices'].isNotEmpty
              ? data['devices'][0]['imei'] ?? '' // 첫 번째 기기의 IMEI
              : '',
          'contact': data['contact'] ?? '', // 연락처
          'bank': data['bankName'] ?? '', // 은행명
          'accountHolder': data['accountHolder'] ?? '', // 예금주
        };
      }).toList();
    } catch (e) {
      print('Error fetching records: $e');
      throw Exception('Failed to fetch records');
    }
  }

  static String _formatMap(Map<String, bool> map) {
    return map.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
  }

  static Future<void> saveRepairAgreement({
    required RepairRequestModel repairRequest,
    required Uint8List pdfData,
    Uint8List? imageData,
  }) async {
    try {
      final pdfFileName = '${repairRequest.nameForStorage}.pdf';
      final pdfUrl = await uploadFile(pdfData, pdfFileName);

      String? imageUrl;
      if (imageData != null) {
        final imageFileName = '${repairRequest.nameForStorage}-image.png';
        imageUrl = await uploadFile(imageData, imageFileName);
      }

      final repairData = repairRequest.toMap();
      repairData['pdfUrl'] = pdfUrl;
      repairData['imageUrl'] = imageUrl;
      repairData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('repairAgreements').add(repairData);
      print('Repair agreement saved successfully.');
    } catch (e) {
      print('Error saving repair agreement: $e');
      throw Exception('Failed to save repair agreement.');
    }
  }
}
