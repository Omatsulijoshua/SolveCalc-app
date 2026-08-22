import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/services/storage_service.dart';

class PremiumState {
  final bool isPremium;
  final bool isPurchasing;
  final String? errorMessage;
  final String priceFormatted;

  const PremiumState({
    required this.isPremium,
    this.isPurchasing = false,
    this.errorMessage,
    this.priceFormatted = AppConstants.proLifetimePrice,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isPurchasing,
    String? errorMessage,
    String? priceFormatted,
    bool clearError = false,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      priceFormatted: priceFormatted ?? this.priceFormatted,
    );
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PremiumNotifier(storage);
});

class PremiumNotifier extends StateNotifier<PremiumState> {
  final StorageService _storage;

  PremiumNotifier(this._storage)
      : super(PremiumState(
          isPremium: _storage.isPremium(),
        ));

  Future<bool> purchaseLifetimePro() async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      // Simulate/trigger cross-platform payment processing for iOS (StoreKit) & Android (Google Play)
      await Future.delayed(const Duration(milliseconds: 1200));

      await _storage.setPremium(true);
      state = state.copyWith(
        isPremium: true,
        isPurchasing: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Purchase could not be completed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final isPro = _storage.isPremium();
      state = state.copyWith(
        isPremium: isPro,
        isPurchasing: false,
        clearError: true,
      );
      return isPro;
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Unable to restore purchases.',
      );
      return false;
    }
  }

  Future<void> setPremiumDirectly(bool isPro) async {
    await _storage.setPremium(isPro);
    state = state.copyWith(isPremium: isPro, isPurchasing: false);
  }
}
