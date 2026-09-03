import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The deployment environment supplied with `--dart-define=APP_ENV=...`.
const String appEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: 'development',
);

/// Screen capture protection is deliberately an explicit production switch.
const bool isProductionEnvironment = appEnvironment == 'production';

abstract final class AppScreenProtection {
  static const MethodChannel _channel = MethodChannel(
    'com.brinda.smart_teacher_mobile/screen_protection',
  );

  /// Configures native, app-wide capture protection before the first app frame.
  static Future<void> configure({
    bool enabled = isProductionEnvironment,
  }) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    await _channel.invokeMethod<void>('setEnabled', <String, bool>{
      'enabled': enabled,
    });
  }
}
