import 'dart:async';
import 'dart:io';

import 'package:breez/logger.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuthenticationService {
  LocalAuthenticationService();

  final _auth = LocalAuthentication();

  Future<LocalAuthenticationOption> get localAuthenticationOption async =>
      await _getLocalAuthenticationOption();

  Future<LocalAuthenticationOption> _getLocalAuthenticationOption() async {
    final availableBiometrics = await _auth.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.face)) {
      return Platform.isIOS
          ? LocalAuthenticationOption.FACE_ID
          : LocalAuthenticationOption.FACE;
    }
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Platform.isIOS
          ? LocalAuthenticationOption.TOUCH_ID
          : LocalAuthenticationOption.FINGERPRINT;
    }
    return LocalAuthenticationOption.NONE;
  }

  Future<bool> authenticate({String localizedReason}) async {
    try {
      return await _auth.authenticate(
        options: const AuthenticationOptions(
            biometricOnly: true, useErrorDialogs: false),
        localizedReason: localizedReason ?? 'Authenticate to Sign-In.',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(biometricHint: ""),
          IOSAuthMessages(),
        ],
      );
    } on PlatformException catch (error) {
      if (error.code == "LockedOut" || error.code == "PermanentlyLockedOut") {
        throw error.message;
      }
      log.severe("Error Code: ${error.code} - Message: ${error.message}");
      await _auth.stopAuthentication();
      return false;
    }
  }

  Future stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}

enum LocalAuthenticationOption {
  FACE,
  FACE_ID,
  FINGERPRINT,
  TOUCH_ID,
  NONE,
}
