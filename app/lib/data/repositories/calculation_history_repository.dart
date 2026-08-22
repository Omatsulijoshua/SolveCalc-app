import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../models/calculation_item.dart';
import '../services/storage_service.dart';

final calculationHistoryRepositoryProvider =
    Provider<CalculationHistoryRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CalculationHistoryRepository(storage);
});

class CalculationHistoryRepository {
  final StorageService _storage;

  CalculationHistoryRepository(this._storage);

  List<CalculationItem> getHistory() {
    final list = _storage.getCalculationHistory();
    return list.map((m) => CalculationItem.fromJson(m)).toList();
  }

  Future<void> addCalculation(CalculationItem item) async {
    final history = getHistory();
    history.insert(0, item);
    // Limit to last 200 items
    if (history.length > 200) {
      history.removeLast();
    }
    await _storage.saveCalculationHistory(history.map((e) => e.toJson()).toList());
  }

  Future<void> deleteItem(String id) async {
    final history = getHistory();
    history.removeWhere((item) => item.id == id);
    await _storage.saveCalculationHistory(history.map((e) => e.toJson()).toList());
  }

  Future<void> toggleFavorite(String id) async {
    final history = getHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = history[index];
      history[index] = item.copyWith(isFavorite: !item.isFavorite);
      await _storage.saveCalculationHistory(history.map((e) => e.toJson()).toList());
    }
  }

  Future<void> clearAll() async {
    await _storage.saveCalculationHistory([]);
  }
}
