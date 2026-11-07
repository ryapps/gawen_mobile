import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the API base URL from the bundled environment file', () async {
    await AppConfig.load();

    expect(AppConfig.baseUrl, 'http://localhost:3000');
  });
}
