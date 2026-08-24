import 'package:city_guide_app/core/database/app_database.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/custom_places/domain/entity/custom_place.dart';
import 'package:city_guide_app/features/custom_places/domain/repo_contract/custom_places_repo.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: CustomPlacesRepo)
class CustomPlacesRepoImpl implements CustomPlacesRepo {
  const CustomPlacesRepoImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<CustomPlace>> watchCustomPlaces() => (_database.select(
    _database.customPlaceEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch().map(
        (rows) => rows.map(_toEntity).toList(growable: false),
  );

  @override
  Future<AppResult<void>> createCustomPlace({
    required String name,
    required PlaceCategory category,
    required GeoPoint location,
    String? address,
    String? note,
  }) async {
    final now = DateTime.now();
    await _database
        .into(_database.customPlaceEntries)
        .insert(
      CustomPlaceEntriesCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        category: category.name,
        latitude: location.latitude,
        longitude: location.longitude,
        address: Value(address),
        note: Value(note),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return const Success(null);
  }

  @override
  Future<AppResult<void>> updateCustomPlace({
    required String id,
    required String name,
    required PlaceCategory category,
    String? address,
    String? note,
  }) async {
    await (_database.update(
      _database.customPlaceEntries,
    )..where((t) => t.id.equals(id))).write(
      CustomPlaceEntriesCompanion(
        name: Value(name),
        category: Value(category.name),
        address: Value(address),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return const Success(null);
  }

  @override
  Future<AppResult<void>> deleteCustomPlace(String id) async {
    await (_database.delete(
      _database.customPlaceEntries,
    )..where((t) => t.id.equals(id))).go();
    return const Success(null);
  }

  CustomPlace _toEntity(CustomPlaceEntry row) => CustomPlace(
    id: row.id,
    name: row.name,
    category: PlaceCategory.values.byName(row.category),
    location: GeoPoint(latitude: row.latitude, longitude: row.longitude),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    address: row.address,
    note: row.note,
  );
}