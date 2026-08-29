import 'package:city_guide_app/features/custom_places/domain/entity/custom_place.dart';
import 'package:city_guide_app/features/custom_places/domain/use_cases/create_custom_place_usecase.dart';
import 'package:city_guide_app/features/custom_places/presentation/view_model/custom_place_form_state.dart';
import 'package:city_guide_app/features/favorites/domain/use_cases/toggle_favorite_usecase.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomPlaceFormCubit extends Cubit<CustomPlaceFormState> {
  CustomPlaceFormCubit(
    this._createCustomPlace,
    this._toggleFavorite,
    GeoPoint initialLocation,
  ) : super(CustomPlaceFormState(location: initialLocation));

  final CreateCustomPlaceUseCase _createCustomPlace;
  final ToggleFavoriteUseCase _toggleFavorite;

  void updateLocation(GeoPoint location) =>
      emit(state.copyWith(location: location));

  void setName(String name) => emit(state.copyWith(name: name));

  void setCategory(PlaceCategory category) =>
      emit(state.copyWith(category: category));

  void setAddress(String address) => emit(state.copyWith(address: address));

  void setNote(String note) => emit(state.copyWith(note: note));

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _createCustomPlace(
      name: state.name.trim(),
      category: state.category,
      location: state.location,
      address: state.address.trim().isEmpty ? null : state.address.trim(),
      note: state.note.trim().isEmpty ? null : state.note.trim(),
    );
    await result.fold(
      onSuccess: (CustomPlace place) async {
        await _toggleFavorite(place.toPlaceSummary(), isFavorite: false);
        emit(state.copyWith(isSaving: false, saved: true));
      },
      onFailure: (failure) async => emit(
        state.copyWith(isSaving: false, errorMessage: failure.message),
      ),
    );
  }
}