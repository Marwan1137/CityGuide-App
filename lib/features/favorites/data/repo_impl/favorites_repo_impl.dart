import 'package:city_guide_app/core/database/app_database.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/favorites/domain/entity/favorite.dart';
import 'package:city_guide_app/features/favorites/domain/repo_contract/favorites_repo.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FavoritesRepo)
class FavoritesRepoImpl implements FavoritesRepo {
  const FavoritesRepoImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<Favorite>> watchFavorites() => (_database.select(
    _database.favoritePlaces,
  )..orderBy([(t) => OrderingTerm.desc(t.savedAt)])).watch().map(
        (rows) => rows.map(_toEntity).toList(growable: false),
  );

  @override
  Stream<bool> watchIsFavorite(String placeId) =>
      (_database.select(
        _database.favoritePlaces,
      )..where((t) => t.id.equals(placeId))).watchSingleOrNull().map(
            (row) => row != null,
      );

  @override
  Future<AppResult<void>> addFavorite(PlaceSummary place) async {
    await _database
        .into(_database.favoritePlaces)
        .insertOnConflictUpdate(
      FavoritePlacesCompanion.insert(
        id: place.id,
        name: place.name,
        category: place.category.name,
        latitude: place.location.latitude,
        longitude: place.location.longitude,
        address: Value(place.address),
        rating: Value(place.rating),
        photoUrl: Value(place.photoUrl),
        savedAt: DateTime.now(),
      ),
    );
    return const Success(null);
  }

  @override
  Future<AppResult<void>> removeFavorite(String placeId) async {
    await (_database.delete(
      _database.favoritePlaces,
    )..where((t) => t.id.equals(placeId))).go();
    return const Success(null);
  }

  Favorite _toEntity(FavoritePlace row) => Favorite(
    place: PlaceSummary(
      id: row.id,
      name: row.name,
      category: PlaceCategory.values.byName(row.category),
      location: GeoPoint(latitude: row.latitude, longitude: row.longitude),
      address: row.address,
      rating: row.rating,
      photoUrl: row.photoUrl,
    ),
    savedAt: row.savedAt,
  );
}