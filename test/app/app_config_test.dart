import 'package:fluxo_financeiro/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aceita endpoint HTTPS sem credenciais embutidas', () {
    final config = AppConfig(
      apiBaseUrl: 'https://api.example.com',
      useMockApi: false,
    );

    expect(config.apiBaseUrl, 'https://api.example.com');
    expect(config.useMockApi, isFalse);
  });

  test('rejeita HTTP e credenciais na URL', () {
    expect(
      () => AppConfig(apiBaseUrl: 'http://api.example.com', useMockApi: false),
      throwsArgumentError,
    );
    expect(
      () => AppConfig(
        apiBaseUrl: 'https://user:secret@api.example.com',
        useMockApi: false,
      ),
      throwsArgumentError,
    );
  });
}
