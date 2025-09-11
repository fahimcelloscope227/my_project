
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOptions: IOSOptions(
    //   accessibility: IOSAccessibility.biometry_current_set,
    // ),
  );

  static const _platform = MethodChannel('biometric_auth');

  // Capture biometric using native platform implementation
  Future<String> captureBiometric() async {
    try {
      // Check device support first
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        throw Exception('Biometric authentication is not supported on this device');
      }

      // Check biometric availability status
      final status = await getBiometricStatus();
      if (!status['available']) {
        String errorMessage = 'Biometric authentication is not available';
        switch (status['status']) {
          case 'BIOMETRIC_ERROR_NO_HARDWARE':
            errorMessage = 'No biometric hardware available on this device';
            break;
          case 'BIOMETRIC_ERROR_HW_UNAVAILABLE':
            errorMessage = 'Biometric hardware is currently unavailable';
            break;
          case 'BIOMETRIC_ERROR_NONE_ENROLLED':
            errorMessage = 'No biometrics are enrolled. Please add a fingerprint or face in device settings';
            break;
          case 'BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED':
            errorMessage = 'Security update required for biometric authentication';
            break;
          case 'BIOMETRIC_ERROR_UNSUPPORTED':
            errorMessage = 'Biometric authentication is not supported';
            break;
        }
        throw Exception(errorMessage);
      }

      // Call native method to capture biometric
      final String template = await _platform.invokeMethod('captureBiometric');

      if (template.isEmpty) {
        throw Exception('Failed to capture biometric template');
      }

      return template;
    } on PlatformException catch (e) {
      // Handle platform-specific errors
      switch (e.code) {
        case 'NO_HARDWARE':
          throw Exception('No biometric hardware available on this device');
        case 'HW_UNAVAILABLE':
          throw Exception('Biometric hardware is currently unavailable');
        case 'NONE_ENROLLED':
          throw Exception('No biometrics are enrolled. Please add a fingerprint or face in device settings');
        case 'AUTHENTICATION_FAILED':
          throw Exception('Biometric authentication failed. Please try again');
        case 'BIOMETRIC_ERROR':
          throw Exception('Biometric authentication error: ${e.message ?? 'Unknown error'}');
        case 'USER_CANCELED':
          throw Exception('Biometric authentication was canceled by user');
        case 'TIMEOUT':
          throw Exception('Biometric authentication timed out');
        case 'TOO_MANY_ATTEMPTS':
          throw Exception('Too many failed attempts. Please try again later');
        case 'LOCKOUT':
          throw Exception('Biometric authentication is temporarily locked');
        case 'LOCKOUT_PERMANENT':
          throw Exception('Biometric authentication is permanently locked');
        default:
          throw Exception('Biometric authentication failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error during biometric capture: $e');
    }
  }

  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      final bool isSupported = await _platform.invokeMethod('isDeviceSupported');
      return isSupported;
    } on PlatformException catch (e) {
      print("Error checking device support: ${e.message}");
      return false;
    }
  }

  // Check biometric availability status with detailed information
  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      final Map<dynamic, dynamic> status = await _platform.invokeMethod('isBiometricAvailable');
      return Map<String, dynamic>.from(status);
    } on PlatformException catch (e) {
      print("Error getting biometric status: ${e.message}");
      return {
        'available': false,
        'status': 'ERROR',
        'error': e.message
      };
    }
  }

  // Store biometric template securely
  Future<void> storeBiometricTemplate(String template1, String template2) async {
    try {
      // Create a combined hash of both templates
      final combinedTemplate = template1;
      final bytes = utf8.encode(combinedTemplate);
      final digest = sha256.convert(bytes);

      await _storage.write(
        key: 'biometric_template',
        value: digest.toString(),
      );
    } catch (e) {
      throw Exception('Failed to store biometric template: $e');
    }
  }
// Verify biometric template - REAL IMPLEMENTATION
  Future<bool> verifyBiometric(String capturedTemplate) async {
    try {
      dev.log("legacy");
      dev.log("capturedTemplate.isEmpty=== ${capturedTemplate.isEmpty}");
      dev.log("capturedTemplate=== ${capturedTemplate}");

      // 1. Input validation
      if (capturedTemplate.isEmpty) {
        throw Exception('Invalid captured template - template cannot be empty');
      }

      // 2. Get stored enrollment data
      final enrollmentDataJson = await _storage.read(key: 'biometric_enrollment_data');
      final templateData = await _storage.read(key: 'biometric_template');
      List<String> storedTemplates = [];

      dev.log("enrollmentDataJson === $enrollmentDataJson");


      if(templateData != null){
        storedTemplates .add(templateData);
      }
      if (enrollmentDataJson != null) {
        // New format with multiple templates and metadata
        final enrollmentData = json.decode(enrollmentDataJson) as Map<String, dynamic>;
        final templates = enrollmentData['templates'] as List<dynamic>?;

        if (templates != null && templates.isNotEmpty) {
          storedTemplates = templates.cast<String>();

          // Verify device consistency for security
          // final enrolledDeviceId = enrollmentData['device_id'] as String? ?? '';
          // final currentDeviceId = await _getCurrentDeviceId();

          // if (enrolledDeviceId.isNotEmpty && enrolledDeviceId != currentDeviceId) {
          //   throw Exception('Device mismatch - biometric was enrolled on a different device');
          // }
        }
      }

      // 3. Fallback to legacy format if new format not found
      dev.log("storedTemplates === $storedTemplates");
      // if (storedTemplates.isEmpty) {
      //   final legacyTemplate = await _storage.read(key: 'biometric_template');
      //   dev.log("legacyTemplate === $legacyTemplate");
      //   if (legacyTemplate == null) {
      //     dev.log("legacy");
      //     return false;
      //   }
      //
      //   // Legacy hash-based verification
      //   final combinedTemplate = capturedTemplate + capturedTemplate;
      //   final bytes = utf8.encode(combinedTemplate);
      //   final digest = sha256.convert(bytes);
      //   return digest.toString() == legacyTemplate;
      // }

      // 4. Perform advanced biometric matching
      double bestMatchScore = 0.0;
      int bestTemplateIndex = -1;
      Map<String, double> bestAlgorithmScores = {};

      dev.log("storedTemplates === ${storedTemplates.length}");
      for (int i = 0; i < storedTemplates.length; i++) {
        final storedTemplate = storedTemplates[i];

        final bytes = utf8.encode(capturedTemplate);
        final finalCapturedTemplate = sha256.convert(bytes);

        // Calculate comprehensive match score
        final matchScores = await _calculateBiometricMatchScore(finalCapturedTemplate.toString(), storedTemplate);
        final combinedScore = matchScores['combined'] ?? 0.0;
        dev.log("combinedScore === $combinedScore");
        if (combinedScore > bestMatchScore) {
          bestMatchScore = combinedScore;
          bestTemplateIndex = i;
          bestAlgorithmScores = matchScores;
        }
      }

      dev.log("bestTemplateIndex === $bestTemplateIndex");

      // 5. Apply security adjustments
      final finalScore = _applySecurityAdjustments(
          bestMatchScore,
          capturedTemplate,
          storedTemplates[bestTemplateIndex]
      );

      // 6. Determine match result
      const double MATCH_THRESHOLD = 0.75; // 75% similarity required
      dev.log("finalScore ==== $finalScore");
      final bool isMatch = finalScore >= MATCH_THRESHOLD;

      // 7. Update verification statistics
      // await _updateVerificationStats(isMatch, finalScore, bestAlgorithmScores);

      return isMatch;

    } catch (e,st) {
      debugPrint("exception === ${e.toString()}",);
      debugPrintStack(stackTrace: st);
      throw Exception('Failed to verify biometric: $e');
    }
  }

// Calculate comprehensive biometric match score using multiple algorithms
  Future<Map<String, double>> _calculateBiometricMatchScore(String template1, String template2) async {
    try {
      final bytes1 = base64Decode(template1);
      final bytes2 = base64Decode(template2);

      if (bytes1.length != bytes2.length) {
        return {'hamming': 0.0, 'cosine': 0.0, 'jaccard': 0.0, 'entropy': 0.0, 'combined': 0.0};
      }

      // Algorithm 1: Hamming Distance (bit-level comparison)
      double hammingScore = _calculateHammingDistance(bytes1, bytes2);

      // Algorithm 2: Cosine Similarity (vector comparison)
      double cosineScore = _calculateCosineSimilarity(bytes1, bytes2);

      // Algorithm 3: Jaccard Similarity (set comparison)
      double jaccardScore = _calculateJaccardSimilarity(bytes1, bytes2);

      // Algorithm 4: Entropy-based Similarity
      double entropyScore = _calculateEntropySimilarity(bytes1, bytes2);

      // Combined weighted score
      double combinedScore =
          (hammingScore * 0.35) +   // Primary algorithm
              (cosineScore * 0.25) +    // Vector similarity
              (jaccardScore * 0.25) +   // Set similarity
              (entropyScore * 0.15);    // Information similarity

      return {
        'hamming': hammingScore,
        'cosine': cosineScore,
        'jaccard': jaccardScore,
        'entropy': entropyScore,
        'combined': math.min(1.0, math.max(0.0, combinedScore)),
      };

    } catch (e,st) {
      debugPrintStack(stackTrace: st);
      return {'hamming': 0.0, 'cosine': 0.0, 'jaccard': 0.0, 'entropy': 0.0, 'combined': 0.0};
    }
  }

// Hamming Distance calculation (primary algorithm)
  double _calculateHammingDistance(List<int> bytes1, List<int> bytes2) {
    int matchingBits = 0;
    int totalBits = bytes1.length * 8;

    for (int i = 0; i < bytes1.length; i++) {
      int xor = bytes1[i] ^ bytes2[i];
      // Count matching bits
      for (int bit = 0; bit < 8; bit++) {
        if ((xor & (1 << bit)) == 0) {
          matchingBits++;
        }
      }
    }

    return totalBits > 0 ? matchingBits / totalBits : 0.0;
  }

// Cosine Similarity calculation
  double _calculateCosineSimilarity(List<int> bytes1, List<int> bytes2) {
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < bytes1.length; i++) {
      dotProduct += bytes1[i] * bytes2[i];
      norm1 += bytes1[i] * bytes1[i];
      norm2 += bytes2[i] * bytes2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;
    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

// Jaccard Similarity calculation
  double _calculateJaccardSimilarity(List<int> bytes1, List<int> bytes2) {
    Set<int> set1 = bytes1.toSet();
    Set<int> set2 = bytes2.toSet();

    int intersection = set1.intersection(set2).length;
    int union = set1.union(set2).length;

    return union == 0 ? 1.0 : intersection / union;
  }

// Entropy-based Similarity calculation
  double _calculateEntropySimilarity(List<int> bytes1, List<int> bytes2) {
    double entropy1 = _calculateEntropy(bytes1);
    double entropy2 = _calculateEntropy(bytes2);

    if (entropy1 == 0.0 && entropy2 == 0.0) return 1.0;

    double entropyDiff = (entropy1 - entropy2).abs();
    double maxEntropy = math.max(entropy1, entropy2);

    return maxEntropy == 0.0 ? 1.0 : 1.0 - (entropyDiff / maxEntropy);
  }

// Calculate Shannon entropy
  double _calculateEntropy(List<int> bytes) {
    if (bytes.isEmpty) return 0.0;

    Map<int, int> frequency = {};
    for (int byte in bytes) {
      frequency[byte] = (frequency[byte] ?? 0) + 1;
    }

    double entropy = 0.0;
    for (int count in frequency.values) {
      if (count > 0) {
        double probability = count / bytes.length;
        entropy -= probability * (math.log(probability) / math.ln2);
      }
    }

    return entropy;
  }

// Apply security adjustments to prevent attacks
  double _applySecurityAdjustments(double baseScore, String template1, String template2) {
    double adjustedScore = baseScore;

    try {
      // 1. Prevent replay attacks (identical templates)
      if (template1 == template2) {
        adjustedScore *= 0.1; // Severe penalty
      }

      // 2. Check template quality
      if (template1.length < 32 || template2.length < 32) {
        adjustedScore *= 0.5; // Penalty for short templates
      }

      // 3. Template entropy check
      final bytes1 = base64Decode(template1);
      final bytes2 = base64Decode(template2);
      final avgEntropy = (_calculateEntropy(bytes1) + _calculateEntropy(bytes2)) / 2;

      if (avgEntropy > 6.0) {
        adjustedScore *= 1.1; // Bonus for high entropy
      } else if (avgEntropy < 2.0) {
        adjustedScore *= 0.6; // Penalty for low entropy
      }

    } catch (e) {
      adjustedScore *= 0.8; // Penalty for errors
    }

    return math.min(1.0, math.max(0.0, adjustedScore));
  }

  // Check if biometric is enrolled
  Future<bool> isBiometricEnrolled() async {
    try {
      final template = await _storage.read(key: 'biometric_template');
      return template != null;
    } catch (e) {
      return false;
    }
  }

  // Clear biometric data
  Future<void> clearBiometricData() async {
    try {
      await _storage.delete(key: 'biometric_template');
    } catch (e,st) {
      debugPrint("exception === ${e.toString()}",);
      debugPrintStack(stackTrace: st);
      throw Exception('Failed to clear biometric data: $e');
    }
  }


}

