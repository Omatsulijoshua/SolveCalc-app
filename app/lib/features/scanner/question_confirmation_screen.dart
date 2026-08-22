import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/solver_provider.dart';
import '../settings/groq_setup_screen.dart';
import '../solver/solution_screen.dart';

class QuestionConfirmationScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? initialQuestion;

  const QuestionConfirmationScreen({
    super.key,
    this.imagePath,
    this.initialQuestion,
  });

  @override
  ConsumerState<QuestionConfirmationScreen> createState() =>
      _QuestionConfirmationScreenState();
}

class _QuestionConfirmationScreenState
    extends ConsumerState<QuestionConfirmationScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final solverState = ref.read(solverProvider);
    _textController = TextEditingController(
      text: widget.initialQuestion ?? solverState.recognizedQuestion,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _insertSymbol(String symbol) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = selection.isValid
        ? text.replaceRange(selection.start, selection.end, symbol)
        : text + symbol;
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (selection.isValid ? selection.start : text.length) + symbol.length,
      ),
    );
  }

  Future<void> _handleSolve() async {
    final question = _textController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mathematical question.')),
      );
      return;
    }

    ref.read(solverProvider.notifier).updateQuestion(question);
    
    // Navigate to solution screen which will trigger solve()
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SolutionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final storage = ref.watch(storageServiceProvider);
    final hasGroqKey = storage.getGroqApiKey() != null && storage.getGroqApiKey()!.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Confirm Question'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bolt,
              color: hasGroqKey ? const Color(0xFF10B981) : Colors.amber,
            ),
            tooltip: hasGroqKey ? 'Groq AI Active' : 'Setup Groq AI',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Thumbnail if photo was taken
              if (widget.imagePath != null) ...[
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.surfaceColor,
                    image: DecorationImage(
                      image: FileImage(File(widget.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'Recognized Math Question:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Editable Question TextField
              Container(
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor.withAlpha(80)),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: theme.textPrimaryColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. 2x + 5 = 15 or x² + 5x + 6 = 0',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Math Symbol Insertion Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _symbolChip('x'),
                    _symbolChip('y'),
                    _symbolChip('+'),
                    _symbolChip('−'),
                    _symbolChip('='),
                    _symbolChip('²'),
                    _symbolChip('³'),
                    _symbolChip('^'),
                    _symbolChip('√'),
                    _symbolChip('/'),
                    _symbolChip('('),
                    _symbolChip(')'),
                    _symbolChip('sin('),
                    _symbolChip('cos('),
                    _symbolChip('π'),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Retake / Back'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Solve Question',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _handleSolve,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _symbolChip(String symbol) {
    final theme = ref.watch(themeControllerProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.surfaceColor,
        side: BorderSide(color: theme.operatorButtonColor),
        onPressed: () => _insertSymbol(symbol),
      ),
    );
  }
}
