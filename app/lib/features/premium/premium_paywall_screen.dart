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

    final isDark = theme.isDark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF38BDF8).withAlpha(140) : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final checkmarkColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A);
    final ctaButtonBg = isDark ? const Color(0xFF0284C7) : const Color(0xFF1D4ED8);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: premiumState.isPurchasing ? null : _handleRestore,
            child: Text(
              'Restore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          children: [
            // Main Google Pro-Style Offer Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB))
                        .withAlpha(25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Badge: RECOMMENDED
                  Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Header: SolveCalc Pro
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'SolveCalc ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Pro',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Tagline: 75% off lifetime offer
                  Text(
                    '75% off lifetime access',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pill / Chip: All 9 Themes + Camera AI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF38BDF8).withAlpha(30)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.all_inclusive,
                          size: 14,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Lifetime License • Zero Ads',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Price Section: Strikethrough & Big Highlighted Price
                  Text(
                    'NGN 28,500',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'NGN 7,100',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF10B981) : const Color(0xFF047857),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(\$9.99 USD one-time)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'One-time payment • No subscriptions, forever yours',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: ctaButtonBg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      onPressed: premiumState.isPurchasing ? null : _handlePurchase,
                      child: premiumState.isPurchasing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Get SolveCalc Pro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section Title with Sparkle Icon
                  Row(
                    children: [
                      _sparkleIcon(),
                      const SizedBox(width: 10),
                      Text(
                        'SolveCalc Pro Features',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Checklist Items
                  _benefitCheckItem(
                    'Deeper math research and exam prep',
                    'Get expanded access to AI Solver and Learn Mode to break down complex equations with complete working & reasoning.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 16),
                  _benefitCheckItem(
                    'Unlimited camera math snapping',
                    'Scan handwritten notes, assignments, or textbook math problems with high-speed Groq Vision OCR.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 16),
                  _benefitCheckItem(
                    'All 9 premium themes unlocked',
                    'Access Casio Scientific, Pure White, Cyber Neon, OLED Black, Midnight Navy, Sunset Glow, and more.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 16),
                  _benefitCheckItem(
                    'Faster code and math calculations',
                    'High-precision trigonometric, algebraic, and calculus engine with auto-balanced parentheses and zero errors.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 16),
                  _benefitCheckItem(
                    '100% offline calculation engine',
                    'Perform all basic and advanced scientific calculations without requiring an internet connection.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),

                  // INCLUDED Section
                  Text(
                    'INCLUDED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.block, color: Color(0xFFEF4444), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '100% Ad-Free • Forever',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _benefitCheckItem(
                    'Zero interruptions',
                    'All top banner ads and full-screen popup ads are permanently disabled.',
                    textPrimary,
                    textSecondary,
                    checkmarkColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Included with SolveCalc Pro at no additional cost.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Terms and restore footer
            Center(
              child: Text(
                'Compatible with Apple In-App Purchase & Google Play Billing.\nOne-time payment with no recurring subscription fees.',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sparkleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
    );
  }

  Widget _benefitCheckItem(
    String title,
    String description,
    Color textPrimary,
    Color textSecondary,
    Color checkmarkColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check,
            size: 18,
            color: checkmarkColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
