import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solve_calc/core/theme/theme_controller.dart';
import 'package:solve_calc/data/services/storage_service.dart';
import 'package:solve_calc/main.dart';

void main() {
  testWidgets('SolveCalc app smoke and calculation test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'solvecalc_onboarding_complete': true,
      'solvecalc_is_premium': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const SolveCalcApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial calculator display shows 0
    expect(find.text('0'), findsWidgets);

    // Tap 7 + 3 =
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    // Verify result is 10
    expect(find.text('10'), findsOneWidget);
  });
}
