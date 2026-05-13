import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_client.dart';
import '../../data/ingredient_detail_repository.dart';
import '../../domain/ingredient_prices.dart';

// Repository Provider
final ingredientDetailRepositoryProvider = Provider<IngredientDetailRepository>(
  (ref) {
    return IngredientDetailRepository(ref.watch(dioProvider));
  },
);

// State 클래스
class IngredientDetailState {
  final IngredientPrices? prices;
  final bool isLoading;
  final Object? error;

  const IngredientDetailState({
    this.prices,
    this.isLoading = false,
    this.error,
  });

  IngredientDetailState copyWith({
    IngredientPrices? prices,
    bool? isLoading,
    Object? error,
  }) {
    return IngredientDetailState(
      prices: prices ?? this.prices,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier
class IngredientDetailNotifier extends StateNotifier<IngredientDetailState> {
  final IngredientDetailRepository _repository;
  final String _ingredientId;

  IngredientDetailNotifier(this._repository, this._ingredientId)
    : super(const IngredientDetailState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prices = await _repository.fetchPrices(_ingredientId);
      if (!mounted) return;
      state = state.copyWith(prices: prices, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e, isLoading: false);
    }
  }
}

final ingredientDetailProvider = StateNotifierProvider.autoDispose
    .family<IngredientDetailNotifier, IngredientDetailState, String>((
      ref,
      ingredientId,
    ) {
      final repository = ref.watch(ingredientDetailRepositoryProvider);
      return IngredientDetailNotifier(repository, ingredientId);
    });
