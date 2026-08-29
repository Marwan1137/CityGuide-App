final class PlaceModel {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.rating,
    this.photoUrl,
    this.distanceMeters,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final category = json['category'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        category is! String ||
        latitude is! num ||
        longitude is! num) {
      throw const FormatException('Invalid place payload.');
    }

    return PlaceModel(
      id: id,
      name: name,
      category: category,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      address: json['address'] is String ? json['address'] as String : null,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      photoUrl: json['photo_url'] is String
          ? json['photo_url'] as String
          : null,
      distanceMeters: json['distance_meters'] is num
          ? (json['distance_meters'] as num).toDouble()
          : null,
    );
  }

  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String? address;
  final double? rating;
  final String? photoUrl;
  final double? distanceMeters;
}
