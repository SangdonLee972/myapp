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

  

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
