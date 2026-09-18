import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/membership/device_identity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('current reuses one generated device id across concurrent calls', () async {
    SharedPreferences.setMockInitialValues({});
    final service = DeviceIdentityService();

    final identities = await Future.wait([
      service.current(),
      service.current(),
    ]);

    expect(identities[0].deviceId, isNotEmpty);
    expect(identities[0].deviceId, identities[1].deviceId);
    expect(identities[0].platform, identities[1].platform);
  });
}
