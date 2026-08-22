class RemoteAdConfig {
  final bool emergencyAdsDisabled;
  final String primaryProvider;
  final List<String> fallbackProviders;
  final int appOpenCooldownMinutes;
  final int appOpenMaxPerSession;
  final int bannerRefreshSeconds;
  final bool houseAdsFallbackEnabled;
  final String configVersion;
  final DateTime updatedAt;

  const RemoteAdConfig({
    this.emergencyAdsDisabled = false,
    this.primaryProvider = 'admob',
    this.fallbackProviders = const ['network_b', 'network_c', 'house_ad'],
    this.appOpenCooldownMinutes = 15,
    this.appOpenMaxPerSession = 1,
    this.bannerRefreshSeconds = 30,
    this.houseAdsFallbackEnabled = true,
    this.configVersion = 'v42',
    required this.updatedAt,
  });

  static RemoteAdConfig defaultConfig() => RemoteAdConfig(
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'emergencyAdsDisabled': emergencyAdsDisabled,
        'primaryProvider': primaryProvider,
        'fallbackProviders': fallbackProviders,
        'appOpenCooldownMinutes': appOpenCooldownMinutes,
        'appOpenMaxPerSession': appOpenMaxPerSession,
        'bannerRefreshSeconds': bannerRefreshSeconds,
        'houseAdsFallbackEnabled': houseAdsFallbackEnabled,
        'configVersion': configVersion,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory RemoteAdConfig.fromJson(Map<String, dynamic> json) {
    return RemoteAdConfig(
      emergencyAdsDisabled: json['emergencyAdsDisabled'] as bool? ?? false,
      primaryProvider: json['primaryProvider'] as String? ?? 'admob',
      fallbackProviders: (json['fallbackProviders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['network_b', 'network_c', 'house_ad'],
      appOpenCooldownMinutes: json['appOpenCooldownMinutes'] as int? ?? 15,
      appOpenMaxPerSession: json['appOpenMaxPerSession'] as int? ?? 1,
      bannerRefreshSeconds: json['bannerRefreshSeconds'] as int? ?? 30,
      houseAdsFallbackEnabled: json['houseAdsFallbackEnabled'] as bool? ?? true,
      configVersion: json['configVersion'] as String? ?? 'v42',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
