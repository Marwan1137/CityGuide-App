import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:equatable/equatable.dart';

final class City extends Equatable {
  const City({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.governorateEn,
    required this.governorateAr,
    required this.location,
    this.isRemoteResult = false,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String governorateEn;
  final String governorateAr;
  final GeoPoint location;
  final bool isRemoteResult;

  String get bilingualName => nameAr.isEmpty ? nameEn : '$nameEn · $nameAr';

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameAr,
    governorateEn,
    governorateAr,
    location,
    isRemoteResult,
  ];
}
