import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/auth/service/excel_sevice.dart';
import 'package:myapp/auth/service/save_service.dart';
import 'package:myapp/main/main_page.dart';
import 'package:myapp/main/search/searchPage.dart';
import 'package:myapp/main/setting_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 현재 선택된 탭 인덱스

  // 각 탭에 표시될 위젯
  final List<Widget> _pages = [
    const MainPage(), // Main 탭 내용
    const SearchPage(), // Search 탭 내용
    const SettingsPage(), // Settings 탭 내용
  ];

  bool _isDownloading = false;

  Future<void> _downloadExcel(BuildContext context) async {
    if (_isDownloading) return; // 중복 방지
    _isDownloading = true;

    try {
      List<Map<String, dynamic>> data = await SaveService.getSavedRecords();
      Uint8List excelData = await ExcelExportService.generateExcel(data);

      await ExcelExportService.saveExcelFile('phone_purchase.xlsx', excelData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('엑셀 파일이 성공적으로 저장되었습니다.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadExcel(context),
            tooltip: '엑셀 다운로드',
          ),
        ],
      ),
      body: _pages[_currentIndex], // 선택된 탭의 콘텐츠를 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 현재 선택된 탭
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // 선택된 탭 인덱스를 업데이트
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
