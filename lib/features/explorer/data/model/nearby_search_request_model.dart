import 'package:city_guide_app/features/explorer/domain/entity/nearby_search_request.dart';

final class NearbySearchRequestModel {
  const NearbySearchRequestModel({
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.radiusMeters,
    required this.maxResults,
  });

  factory NearbySearchRequestModel.fromEntity(NearbySearchRequest request) =>
      NearbySearchRequestModel(
        latitude: request.center.latitude,
        longitude: request.center.longitude,
        category: request.category.name,
        radiusMeters: request.radiusMeters,
        maxResults: request.maxResults,
      );

  final double latitude;
  final double longitude;
  final String category;
  final int radiusMeters;
  final int maxResults;

  Map<String, Object> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'category': category,
    'radius_meters': radiusMeters,
    'max_results': maxResults,
  };
}
