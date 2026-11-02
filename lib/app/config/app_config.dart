final class AppConfig {
  AppConfig({required this.apiBaseUrl, required this.useMockApi}) {
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty) {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'A URL da API deve usar HTTPS, possuir host e não conter credenciais.',
      );
    }
  }

  factory AppConfig.fromEnvironment() => AppConfig(
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://mock.fluxo-financeiro.invalid',
    ),
    useMockApi: const bool.fromEnvironment('USE_MOCK_API', defaultValue: true),
  );

  final String apiBaseUrl;
  final bool useMockApi;
}
