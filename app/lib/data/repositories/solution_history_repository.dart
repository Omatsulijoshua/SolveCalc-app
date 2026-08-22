import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme_controller.dart';
import '../../domain/solver/solution_models.dart';
import '../services/storage_service.dart';

class SolutionHistoryItem {
  final String id;
  final String? imagePath;
  final SolveResult result;
  final DateTime timestamp;
  final bool isFavorite;

  const SolutionHistoryItem({
    required this.id,
    this.imagePath,
    required this.result,
    required this.timestamp,
    this.isFavorite = false,
  });

  String get formattedTime => DateFormat('MMM d, yyyy • h:mm a').format(timestamp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'result': result.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory SolutionHistoryItem.fromJson(Map<String, dynamic> json) =>
      SolutionHistoryItem(
        id: json['id'] as String? ?? '',
        imagePath: json['imagePath'] as String?,
        result: SolveResult.fromJson(json['result'] as Map<String, dynamic>),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  SolutionHistoryItem copyWith({
    String? id,
    String? imagePath,
    SolveResult? result,
    DateTime? timestamp,
    bool? isFavorite,
  }) =>
      SolutionHistoryItem(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        result: result ?? this.result,
        timestamp: timestamp ?? this.timestamp,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

final solutionHistoryRepositoryProvider =
    Provider<SolutionHistoryRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SolutionHistoryRepository(storage);
});

class SolutionHistoryRepository {
  final StorageService _storage;

  SolutionHistoryRepository(this._storage);

  List<SolutionHistoryItem> getSolutions() {
    final list = _storage.getSolutionHistory();
    return list.map((m) => SolutionHistoryItem.fromJson(m)).toList();
  }

  Future<void> addSolution(SolutionHistoryItem item) async {
    final list = getSolutions();
    list.insert(0, item);
    if (list.length > 100) {
      list.removeLast();
    }
    await _storage.saveSolutionHistory(list.map((e) => e.toJson()).toList());
  }

  Future<void> deleteSolution(String id) async {
    final list = getSolutions();
    list.removeWhere((item) => item.id == id);
    await _storage.saveSolutionHistory(list.map((e) => e.toJson()).toList());
  }

  Future<void> clearAll() async {
    await _storage.saveSolutionHistory([]);
  }
}
