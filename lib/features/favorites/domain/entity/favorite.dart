import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:equatable/equatable.dart';

final class Favorite extends Equatable {
  const Favorite({required this.place, required this.savedAt});

  final PlaceSummary place;
  final DateTime savedAt;

  @override
  List<Object?> get props => [place, savedAt];
}