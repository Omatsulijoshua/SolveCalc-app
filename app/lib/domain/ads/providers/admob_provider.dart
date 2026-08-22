import '../ad_provider.dart';

class AdMobProvider implements AdProvider {
  bool _isInitialized = false;

  @override
  String get providerId => 'admob';

  @override
  String get providerName => 'Google AdMob';

  @override
  Future<void> initialize({required bool isTestMode}) async {
    _isInitialized = true;
  }

  @override
  Future<bool> loadBanner() async {
    return _isInitialized;
  }

  @override
  Future<bool> loadAppOpen() async {
    return _isInitialized;
  }

  @override
  bool isAvailable() => _isInitialized;

  @override
  void dispose() {}
}
