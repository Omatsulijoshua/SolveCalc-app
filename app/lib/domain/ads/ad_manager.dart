import 'ad_provider.dart';
import 'providers/admob_provider.dart';
import 'providers/network_b_provider.dart';
import 'providers/network_c_provider.dart';
import 'providers/house_ad_provider.dart';
import 'remote_ad_config.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();

  AdManager._internal();

  final Map<String, AdProvider> _providers = {
    'admob': AdMobProvider(),
    'network_b': NetworkBProvider(),
    'network_c': NetworkCProvider(),
    'house_ad': HouseAdProvider(),
  };

  RemoteAdConfig _config = RemoteAdConfig.defaultConfig();
  bool _isPremium = false;
  DateTime? _lastAppOpenAdShownAt;
  int _appOpenAdsShownThisSession = 0;

  void initialize({required bool isPremium, RemoteAdConfig? remoteConfig}) {
    _isPremium = isPremium;
    if (remoteConfig != null) {
      _config = remoteConfig;
    }
    for (final provider in _providers.values) {
      provider.initialize(isTestMode: true);
    }
  }

  void updatePremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  void updateConfig(RemoteAdConfig newConfig) {
    _config = newConfig;
  }

  bool get shouldShowAds => !_isPremium && !_config.emergencyAdsDisabled;

  bool get isEmergencyDisabled => _config.emergencyAdsDisabled;

  /// Check whether an app-open ad can be displayed according to frequency and cooldown rules
  bool canShowAppOpenAd() {
    if (!shouldShowAds) return false;

    // Session frequency cap
    if (_appOpenAdsShownThisSession >= _config.appOpenMaxPerSession) {
      return false;
    }

    // Cooldown interval check
    if (_lastAppOpenAdShownAt != null) {
      final elapsed = DateTime.now().difference(_lastAppOpenAdShownAt!);
      if (elapsed.inMinutes < _config.appOpenCooldownMinutes) {
        return false;
      }
    }

    return true;
  }

  void recordAppOpenShown() {
    _lastAppOpenAdShownAt = DateTime.now();
    _appOpenAdsShownThisSession++;
  }

  /// Resolve active provider using the remote waterfall configuration
  AdProvider resolveActiveProvider() {
    // 1. Try primary provider
    final primary = _providers[_config.primaryProvider];
    if (primary != null && primary.isAvailable()) {
      return primary;
    }

    // 2. Try configured fallbacks in order
    for (final fallbackId in _config.fallbackProviders) {
      final fallback = _providers[fallbackId];
      if (fallback != null && fallback.isAvailable()) {
        return fallback;
      }
    }

    // 3. Guaranteed fallback to House Ads
    return _providers['house_ad']!;
  }

  HouseAdProvider get houseAdProvider => _providers['house_ad'] as HouseAdProvider;
}
