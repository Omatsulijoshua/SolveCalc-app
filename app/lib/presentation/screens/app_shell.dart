import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/calculator/calculator_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../widgets/app_open_ad_dialog.dart';
import '../widgets/banner_ad_widget.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    ScannerScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Trigger full screen App-Open banner ad if not Pro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppOpenAdDialog.showIfEligible(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // In-app top banner ad for free-tier users
            const TopBannerAdWidget(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: theme.surfaceColor,
        indicatorColor: theme.primaryColor.withAlpha(50),
        surfaceTintColor: Colors.transparent,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined, color: theme.textSecondaryColor),
            selectedIcon: Icon(Icons.calculate, color: theme.primaryColor),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined, color: theme.textSecondaryColor),
            selectedIcon: Icon(Icons.camera_alt, color: theme.primaryColor),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: theme.textSecondaryColor),
            selectedIcon: Icon(Icons.history, color: theme.primaryColor),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: theme.textSecondaryColor),
            selectedIcon: Icon(Icons.settings, color: theme.primaryColor),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
