import 'package:flutter/material.dart';
import 'package:my_project/features/biometric_auth/services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final  _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _statusMessage = 'Place your finger on the sensor to login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Login'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fingerprint icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.fingerprint,
                size: 120,
                color: _isAuthenticating ? Colors.orange : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Biometric Login',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Authenticate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAuthenticating ? null : _authenticateWithBiometric,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAuthenticating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Authenticate with Fingerprint',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alternative login button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isAuthenticating ? null : _showAlternativeLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Use Alternative Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });

    try {
      // Capture biometric for authentication
      final capturedTemplate = await _biometricService.captureBiometric();

      // Verify against stored template
      final isVerified = await _biometricService.verifyBiometric(capturedTemplate);

      if (isVerified) {
        setState(() {
          _statusMessage = 'Authentication successful!';
        });

        // Show success and navigate to authenticated area
        _showSuccessDialog();
      } else {
        setState(() {
          _statusMessage = 'Authentication failed. Please try again.';
        });

        _showError('Fingerprint does not match. Please try again.');
      }
    } catch (e) {
      _showError('Authentication error: $e');
      setState(() {
        _statusMessage = 'Authentication failed. Please try again.';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 48,
          ),
          title: const Text('Login Successful'),
          content: const Text('You have been successfully authenticated with your biometric data.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAlternativeLogin() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alternative Login'),
          content: const Text(
            'In a real application, you would implement alternative login methods here such as password, PIN, or other authentication methods.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}