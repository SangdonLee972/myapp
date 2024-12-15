import 'package:flutter/material.dart';
import 'package:myapp/main/phonePurchase/used_phone_purchase_page.dart';
import 'package:myapp/main/repiar/repair_concent_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져옴
    final double screenWidth = MediaQuery.of(context).size.width;

    // 아이콘 및 텍스트 크기를 화면 크기에 비례하여 설정
    final double iconSize = screenWidth * 0.06; // 화면 너비의 8%
    final double fontSize = screenWidth * 0.03; // 화면 너비의 4.5%

    return Center(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              minimumSize: Size(screenWidth * 0.4,  screenWidth * 0.25), // 가로 크기를 화면의 40%로 설정
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              minimumSize: Size(screenWidth * 0.4, screenWidth * 0.25), // 가로 크기를 화면의 40%로 설정
            ),
          ),
        ],
      ),
    );
  }
}
