abstract class AdProvider {
  String get providerId;
  String get providerName;

  Future<void> initialize({required bool isTestMode});

  Future<bool> loadBanner();
  Future<bool> loadAppOpen();

  bool isAvailable();
  void dispose();
}
