import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/storage_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'presentation/screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const SolveCalcApp(),
      ),
    ),
  );
}

class SolveCalcApp extends ConsumerWidget {
  const SolveCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final storage = ref.watch(storageServiceProvider);
    final isOnboardingComplete = storage.isOnboardingComplete();

    final baseTheme = themeController.materialThemeData;
    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    return MaterialApp(
      title: 'SolveCalc',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: baseTheme.copyWith(textTheme: textTheme),
      home: isOnboardingComplete ? const AppShell() : const OnboardingScreen(),
    );
  }
}
