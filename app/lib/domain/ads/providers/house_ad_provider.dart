import '../ad_provider.dart';

class HouseAd {
  final String id;
  final String title;
  final String description;
  final String ctaText;
  final String destination;

  const HouseAd({
    required this.id,
    required this.title,
    required this.description,
    required this.ctaText,
    required this.destination,
  });
}

class HouseAdProvider implements AdProvider {
  static const List<HouseAd> defaultHouseAds = [
    HouseAd(
      id: 'house_pro_lifetime',
      title: 'Upgrade to SolveCalc Pro — \$10 USD',
      description: 'Remove all ads forever & unlock all 9 premium calculator themes.',
      ctaText: 'GO PRO',
      destination: 'paywall',
    ),
    HouseAd(
      id: 'house_casio_theme',
      title: 'Retro Casio Scientific Theme Available!',
      description: 'Switch to iconic vintage calculator green LCD matrix styling.',
      ctaText: 'TRY THEME',
      destination: 'themes',
    ),
    HouseAd(
      id: 'house_groq_ai',
      title: 'Snap & Solve Any Math Equation',
      description: 'Ultra-fast step-by-step camera math recognition with Groq AI.',
      ctaText: 'SCAN NOW',
      destination: 'scanner',
    ),
  ];

  @override
  String get providerId => 'house_ad';

  @override
  String get providerName => 'SolveCalc House Ads';

  @override
  Future<void> initialize({required bool isTestMode}) async {}

  @override
  Future<bool> loadBanner() async => true;

  @override
  Future<bool> loadAppOpen() async => true;

  @override
  bool isAvailable() => true;

  @override
  void dispose() {}

  HouseAd getRandomHouseAd() {
    final idx = DateTime.now().second % defaultHouseAds.length;
    return defaultHouseAds[idx];
  }
}
