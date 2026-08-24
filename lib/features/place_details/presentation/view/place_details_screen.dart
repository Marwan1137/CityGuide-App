import 'package:city_guide_app/app/routing/app_router.dart';
import 'package:city_guide_app/features/place_details/presentation/view_model/place_details_cubit.dart';
import 'package:city_guide_app/features/place_details/presentation/view_model/place_details_state.dart';
import 'package:city_guide_app/features/place_details/presentation/widgets/place_details_content.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:city_guide_app/shared/widgets/navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({required this.place, super.key});

  final PlaceSummary place;

  @override
  Widget build(BuildContext context) =>
      BlocListener<PlaceDetailsCubit, PlaceDetailsState>(
        listenWhen: (previous, current) =>
            previous.directionsErrorMessage != current.directionsErrorMessage,
        listener: (context, state) {
          final message = state.directionsErrorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        child: NavigationShell(
          currentIndex: 0,
          onDestinationSelected: (index) =>
              _onDestinationSelected(context, index),
          child: Scaffold(
            body: BlocBuilder<PlaceDetailsCubit, PlaceDetailsState>(
              builder: (context, state) => PlaceDetailsContent(
                place: state.place,
                placeDetail: state.placeDetail,
                isLaunchingDirections: state.isLaunchingDirections,
                isFavorite: state.isFavorite,
                lastDetailUpdatedAt: state.lastDetailUpdatedAt,
                detailErrorMessage: state.detailErrorMessage,
                onOpenDirections:
                    context.read<PlaceDetailsCubit>().openDirections,
                onToggleFavorite:
                    context.read<PlaceDetailsCubit>().toggleFavorite,
                onRetryDetail:
                    context.read<PlaceDetailsCubit>().retryLoadDetail,
              ),
            ),
          ),
        ),
      );

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).maybePop();
      case 1:
        context.go(AppRoutes.citySearch);
      case 3:
        context.go(AppRoutes.favorites);
      case 2:
        context.push('/add-custom-place');
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorites will be connected in its feature branch.'),
          ),
        );
    }
  }
}
