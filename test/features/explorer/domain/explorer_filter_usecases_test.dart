import 'package:city_guide_app/core/error/failure.dart';
import 'package:city_guide_app/core/utils/app_result.dart';
import 'package:city_guide_app/features/explorer/domain/entity/explorer_filters.dart';
import 'package:city_guide_app/features/explorer/domain/repo_contract/explorer_filter_preferences_repo.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/load_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/reset_explorer_filters_usecase.dart';
import 'package:city_guide_app/features/explorer/domain/use_cases/save_explorer_filters_usecase.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements ExplorerFilterPreferencesRepo {}

void main() {
  late _MockRepo repo;
  late LoadExplorerFiltersUseCase load;
  late SaveExplorerFiltersUseCase save;
  late ResetExplorerFiltersUseCase reset;

  setUpAll(() => registerFallbackValue(const ExplorerFilters()));

  setUp(() {
    repo = _MockRepo();
    load = LoadExplorerFiltersUseCase(repo);
    save = SaveExplorerFiltersUseCase(repo);
    reset = ResetExplorerFiltersUseCase(repo);
  });

  test('load and reset trigger their repository contracts once', () async {
    when(
      () => repo.load(),
    ).thenAnswer((_) async => const Success(ExplorerFilters()));
    when(() => repo.reset()).thenAnswer((_) async => const Success(null));

    await load();
    await reset();

    verify(() => repo.load()).called(1);
    verify(() => repo.reset()).called(1);
  });

  test(
    'save accepts only supported category and distance combinations',
    () async {
      const supported = ExplorerFilters(
        category: PlaceCategory.restaurant,
        radiusMeters: 10000,
      );
      when(
        () => repo.save(supported),
      ).thenAnswer((_) async => const Success(null));

      final saved = await save(supported);
      final invalidCategory = await save(
        const ExplorerFilters(category: PlaceCategory.custom),
      );
      final invalidRadius = await save(
        const ExplorerFilters(radiusMeters: 2000),
      );

      expect(saved, isA<Success<void>>());
      expect(
        (invalidCategory as Error<void>).failure,
        isA<ValidationFailure>(),
      );
      expect((invalidRadius as Error<void>).failure, isA<ValidationFailure>());
      verify(() => repo.save(supported)).called(1);
      verifyNoMoreInteractions(repo);
    },
  );
}
