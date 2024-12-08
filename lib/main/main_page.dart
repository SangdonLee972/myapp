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
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 중고폰 매입 동의서 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsedPhonePurchasePage(),
                  ),
                );
              },
              child: const Text('중고폰 매입 동의서'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 수리 동의서 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RepairConsentPage(),
                  ),
                );
              },
              child: const Text('수리 동의서'),
            ),
          ],
        ),
      );
  }
}
