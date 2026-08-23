import 'package:city_guide_app/features/place_details/domain/entity/place_detail.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:equatable/equatable.dart';

final class PlaceDetailsState extends Equatable {
  const PlaceDetailsState({
    required this.place,
    this.isLaunchingDirections = false,
    this.directionsErrorMessage,
    this.placeDetail,
    this.isLoadingDetail = false,
    this.isFavorite = false,
    this.lastDetailUpdatedAt,
    this.detailErrorMessage,
  });

  final PlaceSummary place;
  final bool isLaunchingDirections;
  final String? directionsErrorMessage;
  final PlaceDetail? placeDetail;
  final bool isLoadingDetail;
  final bool isFavorite;
  final DateTime? lastDetailUpdatedAt;
  final String? detailErrorMessage;

  PlaceDetailsState copyWith({
    PlaceSummary? place,
    bool? isLaunchingDirections,
    String? directionsErrorMessage,
    PlaceDetail? placeDetail,
    bool? isLoadingDetail,
    bool? isFavorite,
    DateTime? lastDetailUpdatedAt,
    String? detailErrorMessage,
  }) => PlaceDetailsState(
    place: place ?? this.place,
    isLaunchingDirections: isLaunchingDirections ?? this.isLaunchingDirections,
    directionsErrorMessage: directionsErrorMessage,
    placeDetail: placeDetail ?? this.placeDetail,
    isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    isFavorite: isFavorite ?? this.isFavorite,
    lastDetailUpdatedAt: lastDetailUpdatedAt ?? this.lastDetailUpdatedAt,
    detailErrorMessage: detailErrorMessage,
  );

  @override
  List<Object?> get props => [
    place,
    isLaunchingDirections,
    directionsErrorMessage,
    placeDetail,
    isLoadingDetail,
    isFavorite,
    lastDetailUpdatedAt,
    detailErrorMessage,
  ];
}