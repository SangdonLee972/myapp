import 'package:flutter/material.dart';

class UsedPhonePurchasePage extends StatefulWidget {
  const UsedPhonePurchasePage({Key? key}) : super(key: key);

  @override
  State<UsedPhonePurchasePage> createState() => _UsedPhonePurchasePageState();
}

class _UsedPhonePurchasePageState extends State<UsedPhonePurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UsedPhonePurchasePage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Do you consent to the repair?',
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen with a result
                Navigator.pop(context, true); // true for consent
              },
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen with a result
                Navigator.pop(context, false); // false for no consent
              },
              child: const Text('No'),
            ),
          ],
        ),
      ),
    );
  }
}
