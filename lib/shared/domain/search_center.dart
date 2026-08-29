import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:equatable/equatable.dart';

enum SearchCenterSource { device, selectedCity, map }

final class SearchCenter extends Equatable {
  const SearchCenter({required this.point, required this.source, this.label});

  final GeoPoint point;
  final SearchCenterSource source;
  final String? label;

  @override
  List<Object?> get props => [point, source, label];
}
