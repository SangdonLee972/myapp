import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/model/used_phone_purchase.dart';
import 'dart:typed_data';

class SaveService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  /// Firebase Storage에 파일 업로드
  static Future<String> uploadFile(Uint8List fileData, String fileName) async {
    final storageRef = _storage.ref('agreements/$fileName');
    await storageRef.putData(fileData);
    return await storageRef.getDownloadURL();
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
}
