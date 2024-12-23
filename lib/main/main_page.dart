import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth/page/login_page.dart';
import 'package:myapp/auth/service/excel_sevice.dart';
import 'package:myapp/auth/service/save_service.dart';
import 'package:myapp/main/phonePurchase/used_phone_purchase_page.dart';
import 'package:myapp/main/repiar/repair_concent_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // 로그인되지 않은 상태
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  bool _isDownloading = false;

  Future<void> _downloadExcel(BuildContext context) async {
    if (_isDownloading) return; // 중복 방지
    _isDownloading = true;

    try {
      List<Map<String, dynamic>> purchasedata =
          await SaveService.getSavedRecords();
      List<Map<String, dynamic>> repairdata =
          await SaveService.getRepairRecords();
      // 엑셀 생성
      Uint8List excelData = await ExcelExportService.generateExcel(
        purchaseData: purchasedata,
        repairData: repairdata,
      );

      String? filePath = await ExcelExportService.saveExcelFile(
          'phone_purchase.xlsx', excelData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('엑셀 파일이 성공적으로 저장되었습니다. 경로: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error downloading Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('엑셀 다운로드 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isDownloading = false; // 다운로드 완료 후 상태 초기화
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져옴
    final double screenWidth = MediaQuery.of(context).size.width;

    // 아이콘 및 텍스트 크기를 화면 크기에 비례하여 설정
    final double iconSize = screenWidth * 0.06; // 화면 너비의 8%
    final double fontSize = screenWidth * 0.03; // 화면 너비의 4.5%

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadExcel(context),
            tooltip: '엑셀 다운로드',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage()), // 이동할 페이지 지정
              );
            },
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 중고폰 매입 동의서 버튼
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsedPhonePurchasePage(),
                  ),
                );
              },
              icon: Icon(
                Icons.phone_android,
                size: iconSize,
                color: Colors.black,
              ), // 동적으로 계산된 아이콘 크기
              label: Text(
                '중고폰 매입 동의서',
                style: TextStyle(
                  fontSize: fontSize, // 동적으로 계산된 텍스트 크기
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 162, 207, 243),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                minimumSize: Size(screenWidth * 0.4,
                    screenWidth * 0.25), // 가로 크기를 화면의 40%로 설정
              ),
            ),
            const SizedBox(width: 16.0), // 버튼 간 간격
            // 수리 동의서 버튼
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RepairConsentPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.build,
                size: iconSize,
                color: Colors.black,
              ), // 동적으로 계산된 아이콘 크기
              label: Text(
                '수리 동의서',
                style: TextStyle(
                  fontSize: fontSize, // 동적으로 계산된 텍스트 크기
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 186, 162, 243),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                minimumSize: Size(screenWidth * 0.4,
                    screenWidth * 0.25), // 가로 크기를 화면의 40%로 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
