import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../presentation/providers/premium_provider.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  Future<void> _handlePurchase() async {
    final success =
        await ref.read(premiumProvider.notifier).purchaseLifetimePro();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🎉 Welcome to SolveCalc Pro Lifetime!\nAll ads removed & all themes unlocked.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleRestore() async {
    final isPro =
        await ref.read(premiumProvider.notifier).restorePurchases();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPro
              ? '✓ Lifetime Pro purchase successfully restored!'
              : 'No previous purchases found for this account.'),
          backgroundColor:
              isPro ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (isPro) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: premiumState.isPurchasing ? null : _handleRestore,
            child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          children: [
            // Pro Crown Icon Badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withAlpha(120),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title & Subtitle
            const Text(
              'SolveCalc Pro Lifetime',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'One-time payment of ${AppConstants.proLifetimeUsdPrice}. Zero subscriptions. Forever yours on iOS & Android.',
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Feature Card List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withAlpha(60)),
              ),
              child: Column(
                children: [
                  _proFeatureRow(
                    Icons.block,
                    '100% Ad-Free Forever',
                    'Removes all app-open full screen and top banner ads completely.',
                    theme,
                  ),
                  const Divider(height: 24),
                  _proFeatureRow(
                    Icons.camera_alt,
                    'Unlimited Camera Math Snapping',
                    'High-speed Groq Vision equation recognition from camera & photos.',
                    theme,
                  ),
                  const Divider(height: 24),
                  _proFeatureRow(
                    Icons.palette,
                    'All 9 Premium Themes Unlocked',
                    'Pure White, Casio Scientific, Cyber Purple, Midnight, and more.',
                    theme,
                  ),
                  const Divider(height: 24),
                  _proFeatureRow(
                    Icons.school,
                    'Full Learn Mode & Step-by-Step AI',
                    'In-depth explanations answering why each step is performed.',
                    theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Pricing Pill Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withAlpha(35),
                    Colors.amber.withAlpha(15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withAlpha(150), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.amber, size: 28),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lifetime License',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pay once, enjoy forever across all devices',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppConstants.proLifetimePrice,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Purchase Button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed:
                  premiumState.isPurchasing ? null : _handlePurchase,
              child: premiumState.isPurchasing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Upgrade to Lifetime Pro (\$10 USD)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
            ),

            const SizedBox(height: 14),

            // Terms & Privacy text
            Center(
              child: Text(
                'Compatible with Apple In-App Purchase & Google Play Billing.\nOne-time payment of \$10 USD with no recurring fees.',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textSecondaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _proFeatureRow(
    IconData icon,
    String title,
    String description,
    CalculatorThemeConfig theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.amber, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textSecondaryColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
