import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/premium/premium_paywall_screen.dart';
import '../providers/premium_provider.dart';

class TopBannerAdWidget extends ConsumerStatefulWidget {
  const TopBannerAdWidget({super.key});

  @override
  ConsumerState<TopBannerAdWidget> createState() => _TopBannerAdWidgetState();
}

class _TopBannerAdWidgetState extends ConsumerState<TopBannerAdWidget> {
  bool _isTemporarilyDismissed = false;

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);

    // Completely hidden for Lifetime Pro users or temporarily dismissed
    if (premiumState.isPremium || _isTemporarilyDismissed) {
      return const SizedBox.shrink();
    }

    final theme = ref.watch(themeControllerProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ad Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AD',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SolveCalc Pro Lifetime — \$10 USD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Remove all banner & full-screen ads forever',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Upgrade Button
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GO PRO',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Dismiss
          GestureDetector(
            onTap: () => setState(() => _isTemporarilyDismissed = true),
            child: Icon(Icons.close, size: 16, color: theme.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
