import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';


class FingerPrintAuth extends StatefulWidget {
  const FingerPrintAuth({super.key});

  @override
  State<FingerPrintAuth> createState() => _FingerPrintAuthState();
}

class _FingerPrintAuthState extends State<FingerPrintAuth> {
  final LocalAuthentication auth = LocalAuthentication();
  String _message = "Not Authenticated";

  Future<void> _authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        setState(() => _message = "No biometrics available");
        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: "Please authenticate with your fingerprint",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      log("${await auth.getAvailableBiometrics()}",name: "getAvailableBiometrics");

      setState(() {
        _message = didAuthenticate ? "Authenticated ✅" : "Failed ❌";
      });
    } catch (e) {
      setState(() => _message = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fingerprint Auth")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text("Authenticate"),
            ),
          ],
        ),
      ),
    );
  }
}
