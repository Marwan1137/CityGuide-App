import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_map_content.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/google_explorer_map.dart';
import 'package:city_guide_app/shared/widgets/friendly_error_view.dart';
import 'package:city_guide_app/shared/widgets/loading_view.dart';
import 'package:city_guide_app/shared/widgets/navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({
    required this.onChooseCity,
    this.mapBuilder,
    super.key,
  });

  final VoidCallback onChooseCity;
  final ExplorerMapBuilder? mapBuilder;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExplorerCubit, ExplorerState>(
        builder: (context, state) {
          if (state is ExplorerLoading) {
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(index, onChooseCity),
              child: const LoadingView(message: 'Finding nearby cafes…'),
            );
          }
          if (state is ExplorerLoaded) {
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(index, onChooseCity),
              child: ExplorerMapContent(
                state: state,
                mapBuilder: mapBuilder ?? _buildGoogleMap,
                onPlaceSelected: context.read<ExplorerCubit>().selectPlace,
                onChooseCity: onChooseCity,
              ),
            );
          }
          if (state is ExplorerError) {
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(index, onChooseCity),
              child: FriendlyErrorView(
                title: 'Nearby search took a detour',
                message: state.message,
                onRetry: context.read<ExplorerCubit>().retry,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );

  static Widget _buildGoogleMap(
    BuildContext context,
    ExplorerLoaded state,
    ValueChanged<String> onPlaceSelected,
  ) => GoogleExplorerMap(state: state, onPlaceSelected: onPlaceSelected);

  static void _onDestinationSelected(int index, VoidCallback onChooseCity) {
    if (index == 1) onChooseCity();
  }
}
