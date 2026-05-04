import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/constants/app_constants.dart';

void main() {
  test('AppConstants exposes the mobile API base URL and timeouts', () {
    expect(AppConstants.apiBaseUrl, 'http://localhost:3000/api/v1');
    expect(AppConstants.requestConnectTimeout, const Duration(seconds: 15));
    expect(AppConstants.requestReceiveTimeout, const Duration(seconds: 20));
  });
}
