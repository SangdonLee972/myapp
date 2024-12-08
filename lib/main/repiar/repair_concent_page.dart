
import 'package:flutter/material.dart';

class RepairConsentPage extends StatefulWidget {
  const RepairConsentPage({Key? key}) : super(key: key);

  @override
  State<RepairConsentPage> createState() => _RepairConsentPageState();
}

class _RepairConsentPageState extends State<RepairConsentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Consent'),
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
