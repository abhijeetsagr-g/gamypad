import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_pc/src/settings/server_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('port validation', () {
    expect(isValidPort(0), isTrue);
    expect(isValidPort(1024), isTrue);
    expect(isValidPort(65535), isTrue);
    expect(isValidPort(80), isFalse);
    expect(isValidPort(65536), isFalse);
    expect(isValidPort(-1), isFalse);
  });

  test(
    'defaults to random port, persists and rejects bad stored values',
    () async {
      SharedPreferences.setMockInitialValues({});
      const repo = SharedPreferencesServerSettingsRepository();
      expect((await repo.load()).isRandomPort, isTrue);

      await repo.save(const ServerSettings(port: 5000));
      expect((await repo.load()).port, 5000);

      SharedPreferences.setMockInitialValues({'server_port': 80});
      expect((await repo.load()).isRandomPort, isTrue);
    },
  );
}
