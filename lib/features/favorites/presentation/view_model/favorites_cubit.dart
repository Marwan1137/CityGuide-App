import 'dart:async';

import 'package:city_guide_app/features/favorites/domain/use_cases/watch_favorites_usecase.dart';
import 'package:city_guide_app/features/favorites/presentation/view_model/favorites_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._watchFavorites) : super(const FavoritesState()) {
    _subscription = _watchFavorites().listen(
          (favorites) => emit(state.copyWith(favorites: favorites)),
    );
  }

  final WatchFavoritesUseCase _watchFavorites;
  late final StreamSubscription<void> _subscription;

  void setCategoryFilter(String? category) => emit(
    category == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(categoryFilter: category),
  );

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}