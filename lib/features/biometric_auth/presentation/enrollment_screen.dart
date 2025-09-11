import 'dart:developer';

import 'package:flutter/material.dart';
import '../services/biometric_service.dart';

class EnrollmentScreen extends StatefulWidget {
  final VoidCallback onEnrollmentComplete;

  const EnrollmentScreen({
    super.key,
    required this.onEnrollmentComplete,
  });

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final BiometricService _biometricService = BiometricService();

  int _currentStep = 0;
  String? _firstTemplate;
  String? _secondTemplate;
  bool _isCapturing = false;
  String _statusMessage = 'Place your finger on the sensor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Enrollment'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: _currentStep / 2,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
            const SizedBox(height: 32),

            // Fingerprint icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.fingerprint,
                size: 120,
                color: _isCapturing ? Colors.orange : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // Step indicator
            Text(
              'Step ${_currentStep + 1} of 2',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Capture button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCapturing ? null : _captureFingerprint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCapturing
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  _currentStep == 0 ? 'Capture First Print' : 'Capture Second Print',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            if (_currentStep == 1) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isCapturing ? null : _completeEnrollment,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Complete Enrollment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _captureFingerprint() async {
    setState(() {
      _isCapturing = true;
      _statusMessage = 'Capturing fingerprint...';
    });

    try {
      final template = await _biometricService.captureBiometric();
      log(template,name: "fingerprint data");

      if (_currentStep == 0) {
        _firstTemplate = template;
        setState(() {
          _currentStep = 1;
          _statusMessage = 'Great! Now place your finger again for verification';
        });
      } else {
        _secondTemplate = template;
        setState(() {
          _statusMessage = 'Second capture complete. Ready to save!';
        });
      }
    } catch (e) {
      _showError('Failed to capture fingerprint: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _completeEnrollment() async {
    if (_firstTemplate == null || _secondTemplate == null) {
      _showError('Please capture both fingerprint samples');
      return;
    }

    setState(() {
      _isCapturing = true;
      _statusMessage = 'Saving biometric data...';
    });

    try {
      await _biometricService.storeBiometricTemplate(_firstTemplate!, _secondTemplate!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric enrollment completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onEnrollmentComplete();
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to save biometric data: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _statusMessage = 'Error occurred. Please try again.';
      });
    }
  }
}