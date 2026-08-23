import 'package:city_guide_app/features/favorites/domain/entity/favorite.dart';
import 'package:equatable/equatable.dart';

final class FavoritesState extends Equatable {
  const FavoritesState({this.favorites = const [], this.categoryFilter});

  final List<Favorite> favorites;
  final String? categoryFilter;

  List<Favorite> get filtered => categoryFilter == null
      ? favorites
      : favorites
      .where((favorite) => favorite.place.category.name == categoryFilter)
      .toList(growable: false);

  FavoritesState copyWith({
    List<Favorite>? favorites,
    String? categoryFilter,
    bool clearFilter = false,
  }) => FavoritesState(
    favorites: favorites ?? this.favorites,
    categoryFilter: clearFilter ? null : (categoryFilter ?? this.categoryFilter),
  );

  @override
  List<Object?> get props => [favorites, categoryFilter];
}