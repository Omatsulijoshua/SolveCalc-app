import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../data/services/storage_service.dart';
import '../../presentation/providers/premium_provider.dart';
import '../premium/premium_paywall_screen.dart';
import 'appearance_settings_screen.dart';
import 'groq_setup_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late StorageService _storage;
  bool _haptic = true;
  bool _scientificDefault = false;
  bool _saveHistory = true;
  bool _learnMode = true;
  String _provider = 'local';
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _storage = ref.read(storageServiceProvider);
    _haptic = _storage.isHapticEnabled();
    _scientificDefault = _storage.isScientificDefault();
    _saveHistory = _storage.isSaveHistoryEnabled();
    _learnMode = _storage.isLearnModeEnabled();
    _provider = _storage.getAiProvider();
    _apiKeyController.text = _storage.getAiApiKey() ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Lifetime Pro Banner
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: premiumState.isPremium
                      ? [
                          const Color(0xFF10B981).withAlpha(200),
                          const Color(0xFF059669),
                        ]
                      : [
                          const Color(0xFFF59E0B),
                          const Color(0xFFD97706),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (premiumState.isPremium
                            ? const Color(0xFF10B981)
                            : Colors.amber)
                        .withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      premiumState.isPremium
                          ? Icons.stars
                          : Icons.workspace_premium,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          premiumState.isPremium
                              ? '✓ SolveCalc Pro Lifetime Active'
                              : 'Upgrade to Lifetime Pro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          premiumState.isPremium
                              ? 'Zero ads • All 9 themes • Unlimited AI'
                              : '${AppConstants.proLifetimeUsdPrice} One-Time • 100% Ad-Free Forever',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section: Appearance
          _sectionHeader('APPEARANCE', theme),
          _cardContainer(
            theme,
            [
              ListTile(
                leading: Icon(Icons.palette_outlined, color: theme.primaryColor),
                title: const Text('Theme & Colors'),
                subtitle: Text('Active: ${theme.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section: Calculator Behavior
          _sectionHeader('CALCULATOR ENGINE', theme),
          _cardContainer(
            theme,
            [
              SwitchListTile(
                secondary: Icon(Icons.functions, color: theme.primaryColor),
                title: const Text('Default to Scientific Mode'),
                subtitle: const Text('Start app in expanded scientific layout'),
                value: _scientificDefault,
                activeThumbColor: theme.primaryColor,
                onChanged: (val) async {
                  setState(() => _scientificDefault = val);
                  await _storage.setScientificDefault(val);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(Icons.vibration, color: theme.primaryColor),
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate subtly on keypress'),
                value: _haptic,
                activeThumbColor: theme.primaryColor,
                onChanged: (val) async {
                  setState(() => _haptic = val);
                  await _storage.setHapticEnabled(val);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(Icons.history, color: theme.primaryColor),
                title: const Text('Save Calculations'),
                subtitle: const Text('Automatically record calculation history'),
                value: _saveHistory,
                activeThumbColor: theme.primaryColor,
                onChanged: (val) async {
                  setState(() => _saveHistory = val);
                  await _storage.setSaveHistoryEnabled(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section: AI Solver & Education
          _sectionHeader('AI MATH SOLVER & SNAPPING', theme),
          _cardContainer(
            theme,
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt, color: theme.primaryColor),
                ),
                title: const Text(
                  'Groq AI Setup (Recommended)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _storage.getGroqApiKey() != null && _storage.getGroqApiKey()!.isNotEmpty
                      ? '✓ Active (Ultra-fast math & photo snapping)'
                      : 'Set up free API key for photo math recognition',
                  style: TextStyle(
                    color: _storage.getGroqApiKey() != null && _storage.getGroqApiKey()!.isNotEmpty
                        ? const Color(0xFF10B981)
                        : theme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
                  );
                  setState(() {});
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(Icons.school_outlined, color: theme.primaryColor),
                title: const Text('Learn Mode'),
                subtitle: const Text('Show educational "Why this step" explanations'),
                value: _learnMode,
                activeThumbColor: theme.primaryColor,
                onChanged: (val) async {
                  setState(() => _learnMode = val);
                  await _storage.setLearnModeEnabled(val);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.dns_outlined, color: theme.primaryColor),
                title: const Text('Active Engine'),
                subtitle: Text(_storage.getGroqApiKey() != null && _storage.getGroqApiKey()!.isNotEmpty
                    ? 'Groq Cloud (Llama 3.3 + Vision)'
                    : (_provider == 'gemini'
                        ? 'Google Gemini API'
                        : 'SolveCalc Deterministic Engine (Offline)')),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section: About
          _sectionHeader('ABOUT', theme),
          _cardContainer(
            theme,
            [
              ListTile(
                leading: Icon(Icons.info_outline, color: theme.primaryColor),
                title: const Text(AppConstants.appName),
                subtitle: const Text('${AppConstants.appTagline} • v${AppConstants.appVersion}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, CalculatorThemeConfig theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _cardContainer(CalculatorThemeConfig theme, List<Widget> children) {
    return Material(
      color: theme.surfaceColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
