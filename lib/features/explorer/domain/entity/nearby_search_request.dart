import 'package:city_guide_app/features/explorer/domain/entity/search_request_cancellation.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:equatable/equatable.dart';

final class NearbySearchRequest extends Equatable {
  const NearbySearchRequest({
    required this.center,
    this.category = PlaceCategory.cafe,
    this.radiusMeters = 3000,
    this.maxResults = 20,
    this.cancellation,
  });

  final GeoPoint center;
  final PlaceCategory category;
  final int radiusMeters;
  final int maxResults;
  final SearchRequestCancellation? cancellation;

  @override
  List<Object> get props => [center, category, radiusMeters, maxResults];
}
