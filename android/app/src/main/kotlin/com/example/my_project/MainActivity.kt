package com.example.my_project


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor
import android.util.Base64
import java.security.MessageDigest
import java.security.SecureRandom
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "biometric_auth"
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceSupported" -> {
                    checkDeviceSupport(result)
                }
                "captureBiometric" -> {
                    captureBiometric(result)
                }
                "isBiometricAvailable" -> {
                    isBiometricAvailable(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        setupBiometricPrompt()
    }

    private fun setupBiometricPrompt() {
        val executor: Executor = ContextCompat.getMainExecutor(this)

        biometricPrompt = BiometricPrompt(this as FragmentActivity,
            executor, object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    pendingResult?.error("BIOMETRIC_ERROR", errString.toString(), errorCode)
                    pendingResult = null
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    // Generate a simulated biometric template based on successful authentication
                    val simulatedTemplate = generateSimulatedTemplate()
                    pendingResult?.success(simulatedTemplate)
                    pendingResult = null
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    pendingResult?.error("AUTHENTICATION_FAILED", "Biometric authentication failed", null)
                    pendingResult = null
                }
            })

        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Authentication")
            .setSubtitle("Use your biometric credential to authenticate")
            .setDescription("Place your finger on the sensor or use face recognition")
            .setNegativeButtonText("Cancel")
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            .build()
    }

    private fun checkDeviceSupport(result: MethodChannel.Result) {
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                result.success(true)
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> {
                result.success(false)
            }
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> {
                result.success(false)
            }
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                result.success(false)
            }
            else -> {
                result.success(false)
            }
        }
    }

    private fun isBiometricAvailable(result: MethodChannel.Result) {
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                result.success(mapOf(
                    "available" to true,
                    "status" to "BIOMETRIC_SUCCESS"
                ))
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_ERROR_NO_HARDWARE"
                ))
            }
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_ERROR_HW_UNAVAILABLE"
                ))
            }
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_ERROR_NONE_ENROLLED"
                ))
            }
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED"
                ))
            }
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_ERROR_UNSUPPORTED"
                ))
            }
            BiometricManager.BIOMETRIC_STATUS_UNKNOWN -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "BIOMETRIC_STATUS_UNKNOWN"
                ))
            }
            else -> {
                result.success(mapOf(
                    "available" to false,
                    "status" to "UNKNOWN"
                ))
            }
        }
    }

    private fun captureBiometric(result: MethodChannel.Result) {
        pendingResult = result

        // Check if biometric authentication is available
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                // Launch biometric prompt
                biometricPrompt.authenticate(promptInfo)
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> {
                result.error("NO_HARDWARE", "No biometric hardware available", null)
                pendingResult = null
            }
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> {
                result.error("HW_UNAVAILABLE", "Biometric hardware unavailable", null)
                pendingResult = null
            }
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                result.error("NONE_ENROLLED", "No biometrics enrolled", null)
                pendingResult = null
            }
            else -> {
                result.error("BIOMETRIC_ERROR", "Biometric authentication not available", null)
                pendingResult = null
            }
        }
    }

    private fun generateSimulatedTemplate(): String {
        // In a real implementation, this would be the actual biometric template
        // For demonstration, we generate a consistent but unique identifier
        // based on device characteristics and current user

        val deviceInfo = android.os.Build.MODEL +
                android.os.Build.MANUFACTURER +
                android.os.Build.SERIAL

        // Add some randomness but make it somewhat consistent for demo
        val random = SecureRandom()
        val randomBytes = ByteArray(16)
        random.nextBytes(randomBytes)

        // Create a hash combining device info and random data
        val messageDigest = MessageDigest.getInstance("SHA-256")
        messageDigest.update(deviceInfo.toByteArray())
        messageDigest.update(randomBytes)

        val hash = messageDigest.digest()
        return Base64.encodeToString(hash, Base64.DEFAULT)
    }
}
