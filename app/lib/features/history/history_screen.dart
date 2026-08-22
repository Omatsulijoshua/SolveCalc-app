import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_presets.dart';
import '../../data/models/calculation_item.dart';
import '../../data/repositories/calculation_history_repository.dart';
import '../../data/repositories/solution_history_repository.dart';
import '../../presentation/providers/calculator_provider.dart';
import '../../core/theme/theme_controller.dart';
import '../solver/solution_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll(BuildContext context, bool isCalculation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear ${isCalculation ? "Calculation" : "Scanned"} History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (isCalculation) {
        await ref.read(calculationHistoryRepositoryProvider).clearAll();
      } else {
        await ref.read(solutionHistoryRepositoryProvider).clearAll();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final calcRepo = ref.watch(calculationHistoryRepositoryProvider);
    final solutionRepo = ref.watch(solutionHistoryRepositoryProvider);

    final calcList = calcRepo.getHistory().where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.expression.toLowerCase().contains(q) ||
          item.result.toLowerCase().contains(q);
    }).toList();

    final solutionList = solutionRepo.getSolutions().where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.result.originalQuestion.toLowerCase().contains(q) ||
          item.result.finalAnswer.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.textSecondaryColor,
          tabs: const [
            Tab(text: 'Calculations'),
            Tab(text: 'Scanned Solutions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () => _confirmClearAll(context, _tabController.index == 0),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: Icon(Icons.search, color: theme.textSecondaryColor),
                filled: true,
                fillColor: theme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Tabs View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Calculations List
                calcList.isEmpty
                    ? _buildEmptyState(
                        'No calculation history',
                        'Calculations performed in SolveCalc will be saved here.',
                        Icons.calculate_outlined,
                        theme,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: calcList.length,
                        itemBuilder: (ctx, i) => _buildCalcItem(calcList[i], theme),
                      ),

                // 2. Scanned Solutions List
                solutionList.isEmpty
                    ? _buildEmptyState(
                        'No scanned solutions',
                        'Scanned and AI-solved math problems will appear here.',
                        Icons.auto_awesome_outlined,
                        theme,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: solutionList.length,
                        itemBuilder: (ctx, i) => _buildSolutionItem(solutionList[i], theme),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcItem(CalculationItem item, CalculatorThemeConfig theme) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await ref.read(calculationHistoryRepositoryProvider).deleteItem(item.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            title: Text(
              item.expression,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textSecondaryColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '= ${item.result}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.formattedTime} • ${item.angleMode}',
                  style: TextStyle(fontSize: 11, color: theme.textSecondaryColor),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite ? const Color(0xFFF59E0B) : theme.textSecondaryColor,
              ),
              onPressed: () async {
                await ref.read(calculationHistoryRepositoryProvider).toggleFavorite(item.id);
                setState(() {});
              },
            ),
            onTap: () {
              // Insert into active calculator
              ref.read(calculatorProvider.notifier).setExpression(item.expression);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loaded "${item.expression}" to calculator'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionItem(SolutionHistoryItem item, CalculatorThemeConfig theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.surfaceColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.primaryColor.withAlpha(30)),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(
          item.result.originalQuestion,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Answer: ${item.result.finalAnswer}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${item.formattedTime} • ${item.result.steps.length} Steps',
              style: TextStyle(fontSize: 11, color: theme.textSecondaryColor),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SolutionScreen(preloadedResult: item.result),
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    CalculatorThemeConfig theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.textSecondaryColor.withAlpha(120)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
