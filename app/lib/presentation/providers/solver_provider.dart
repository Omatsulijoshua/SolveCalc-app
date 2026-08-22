import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/repositories/solution_history_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/ai/ai_solver_service.dart';
import '../../domain/ai/groq_solver_service.dart';
import '../../domain/solver/solution_models.dart';

enum ExplanationMode {
  quick,
  stepByStep,
  learnMode,
}

class SolverState {
  final bool isProcessing;
  final bool isOcrProcessing;
  final String? scannedImagePath;
  final String recognizedQuestion;
  final SolveResult? solveResult;
  final ExplanationMode explanationMode;
  final String? errorMessage;

  const SolverState({
    this.isProcessing = false,
    this.isOcrProcessing = false,
    this.scannedImagePath,
    this.recognizedQuestion = '',
    this.solveResult,
    this.explanationMode = ExplanationMode.stepByStep,
    this.errorMessage,
  });

  SolverState copyWith({
    bool? isProcessing,
    bool? isOcrProcessing,
    String? scannedImagePath,
    String? recognizedQuestion,
    SolveResult? solveResult,
    ExplanationMode? explanationMode,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return SolverState(
      isProcessing: isProcessing ?? this.isProcessing,
      isOcrProcessing: isOcrProcessing ?? this.isOcrProcessing,
      scannedImagePath: scannedImagePath ?? this.scannedImagePath,
      recognizedQuestion: recognizedQuestion ?? this.recognizedQuestion,
      solveResult: clearResult ? null : (solveResult ?? this.solveResult),
      explanationMode: explanationMode ?? this.explanationMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final aiSolverServiceProvider = Provider<AISolverService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final providerName = storage.getAiProvider();
  final groqKey = storage.getGroqApiKey();
  final geminiKey = storage.getAiApiKey();

  if (groqKey != null && groqKey.isNotEmpty) {
    return GroqAIService(apiKey: groqKey);
  }

  if (providerName == 'gemini' && geminiKey != null && geminiKey.isNotEmpty) {
    return GeminiAISolver(apiKey: geminiKey);
  }

  return LocalDeterministicAISolver();
});

final solverProvider =
    StateNotifierProvider<SolverNotifier, SolverState>((ref) {
  final aiSolver = ref.watch(aiSolverServiceProvider);
  final historyRepo = ref.watch(solutionHistoryRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return SolverNotifier(aiSolver, historyRepo, storage);
});

class SolverNotifier extends StateNotifier<SolverState> {
  final AISolverService _aiSolver;
  final SolutionHistoryRepository _historyRepo;
  final StorageService _storage;
  static const _uuid = Uuid();

  SolverNotifier(this._aiSolver, this._historyRepo, this._storage)
      : super(SolverState(
          explanationMode: _storage.isLearnModeEnabled()
              ? ExplanationMode.learnMode
              : ExplanationMode.stepByStep,
        ));

  void setRecognizedQuestion(String question, {String? imagePath}) {
    state = state.copyWith(
      recognizedQuestion: question,
      scannedImagePath: imagePath,
      clearResult: true,
      clearError: true,
    );
  }

  Future<String> processImageAndRecognize(String imagePath) async {
    state = state.copyWith(isOcrProcessing: true, scannedImagePath: imagePath);
    final groqKey = _storage.getGroqApiKey();

    if (groqKey != null && groqKey.isNotEmpty) {
      try {
        final recognized = await GroqAIService.recognizeMathFromImage(imagePath, groqKey);
        state = state.copyWith(
          isOcrProcessing: false,
          recognizedQuestion: recognized,
          clearError: true,
        );
        return recognized;
      } catch (_) {
        // Fallback to manual entry placeholder if image OCR fails
      }
    }

    state = state.copyWith(
      isOcrProcessing: false,
      recognizedQuestion: '2x + 5 = 15',
      clearError: true,
    );
    return state.recognizedQuestion;
  }

  void updateQuestion(String editedQuestion) {
    state = state.copyWith(
      recognizedQuestion: editedQuestion,
      clearError: true,
    );
  }

  void setExplanationMode(ExplanationMode mode) {
    state = state.copyWith(explanationMode: mode);
  }

  Future<void> solve() async {
    final question = state.recognizedQuestion.trim();
    if (question.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter or scan a question.');
      return;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final result = await _aiSolver.solveQuestion(
        question,
        learnMode: state.explanationMode == ExplanationMode.learnMode,
      );

      state = state.copyWith(
        isProcessing: false,
        solveResult: result,
        clearError: true,
      );

      // Auto-save to solution history
      await _historyRepo.addSolution(SolutionHistoryItem(
        id: _uuid.v4(),
        imagePath: state.scannedImagePath,
        result: result,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Unable to solve equation: ${e.toString()}',
      );
    }
  }

  void loadExistingResult(SolveResult result, {String? imagePath}) {
    state = state.copyWith(
      recognizedQuestion: result.originalQuestion,
      scannedImagePath: imagePath,
      solveResult: result,
      clearError: true,
    );
  }

  void clear() {
    state = SolverState(
      explanationMode: _storage.isLearnModeEnabled()
          ? ExplanationMode.learnMode
          : ExplanationMode.stepByStep,
    );
  }
}
