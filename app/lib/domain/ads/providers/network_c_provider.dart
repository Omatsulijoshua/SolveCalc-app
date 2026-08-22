import '../ad_provider.dart';

class NetworkCProvider implements AdProvider {
  bool _isInitialized = false;

  @override
  String get providerId => 'network_c';

  @override
  String get providerName => 'Network C (Unity Ads)';

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
