import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/ads/ad_manager.dart';
import '../../features/premium/premium_paywall_screen.dart';
import '../providers/premium_provider.dart';

class AppOpenAdDialog extends ConsumerStatefulWidget {
  const AppOpenAdDialog({super.key});

  static Future<void> showIfEligible(BuildContext context, WidgetRef ref) async {
    final isPro = ref.read(premiumProvider).isPremium;
    AdManager.instance.updatePremiumStatus(isPro);

    // Enforce multi-network AdManager eligibility & frequency caps
    if (!AdManager.instance.canShowAppOpenAd()) {
      return;
    }

    // Small timeout safe delay to ensure tree is mounted
    await Future.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    AdManager.instance.recordAppOpenShown();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AppOpenAdDialog(),
    );
  }

  @override
  ConsumerState<AppOpenAdDialog> createState() => _AppOpenAdDialogState();
}

class _AppOpenAdDialogState extends ConsumerState<AppOpenAdDialog> {
  int _secondsLeft = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Ad Badge + Countdown Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SPONSORED AD',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: _secondsLeft == 0 ? Colors.white70 : Colors.white24,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: Icon(
                      _secondsLeft == 0 ? Icons.close : Icons.timer,
                      size: 16,
                      color: _secondsLeft == 0 ? Colors.white : Colors.amber,
                    ),
                    label: Text(
                      _secondsLeft == 0 ? 'Skip Ad' : 'Skip in $_secondsLeft s',
                      style: TextStyle(
                        color: _secondsLeft == 0 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: _secondsLeft == 0 ? () => Navigator.of(context).pop() : null,
                  ),
                ],
              ),

              const Spacer(),

              // Ad Content Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.surfaceColor,
                      theme.backgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.withAlpha(120), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withAlpha(30),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withAlpha(100),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tired of Interruptions?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get SolveCalc Pro Lifetime for just ${AppConstants.proLifetimeUsdPrice} and remove ALL ads forever!',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textSecondaryColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _featureRow(Icons.block, 'Zero Banner & App-Open Ads', theme),
                    const SizedBox(height: 8),
                    _benefitItem(Icons.camera_alt, 'Unlimited AI Camera Math Snapping', theme),
                    const SizedBox(height: 8),
                    _benefitItem(Icons.palette, 'Unlock All 9 Themes (White, Casio, etc.)', theme),
                  ],
                ),
              ),

              const Spacer(),

              // Upgrade Action Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.black, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Upgrade to Lifetime Pro — \$10 USD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_secondsLeft == 0)
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Continue with free version',
                      style: TextStyle(color: theme.textSecondaryColor, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, dynamic theme) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _benefitItem(IconData icon, String text, dynamic theme) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
      ],
    );
  }
}
