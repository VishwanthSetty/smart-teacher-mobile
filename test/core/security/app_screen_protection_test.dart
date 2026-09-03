import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/security/app_screen_protection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'com.brinda.smart_teacher_mobile/screen_protection',
  );

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('passes the requested protection state to the native shell', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          received = call;
          return null;
        });

    await AppScreenProtection.configure(enabled: true);

    expect(received?.method, 'setEnabled');
    expect(received?.arguments, <String, bool>{'enabled': true});
  });

  test('development builds can explicitly disable protection', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          received = call;
          return null;
        });

    await AppScreenProtection.configure(enabled: false);

    expect(received?.arguments, <String, bool>{'enabled': false});
  });
}
