import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/membership/membership_service.dart';
import 'package:omnitoolkit/screens/active_devices_screen.dart';

void main() {
  testWidgets('marks current device, masks the device id, and disables removal',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveDeviceCard(
            device: const ActiveDevice(
              email: 'buyer@example.com',
              deviceId: 'abcdefghijklmnop',
              platform: 'android',
            ),
            isCurrentDevice: true,
            onRemove: null,
            formatDate: (_) => 'Unknown',
          ),
        ),
      ),
    );

    expect(find.text('ANDROID (This device)'), findsOneWidget);
    expect(find.text('Device ID: abcd…mnop'), findsOneWidget);
    expect(find.textContaining('abcdefghijklmnop'), findsNothing);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  testWidgets('enables removal for other devices', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveDeviceCard(
            device: const ActiveDevice(
              email: 'buyer@example.com',
              deviceId: 'device-1234',
              platform: 'ios',
            ),
            isCurrentDevice: false,
            onRemove: () => tapped = true,
            formatDate: (_) => '2026-09-18 10:00',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    expect(tapped, isTrue);
    expect(find.text('Device ID: devi…1234'), findsOneWidget);
  });
}
