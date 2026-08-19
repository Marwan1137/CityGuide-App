import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_filter_sheet.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_list_content.dart';
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
            final cubit = context.read<ExplorerCubit>();
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(index, onChooseCity),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: state.viewMode == ExplorerViewMode.map
                        ? ExplorerMapContent(
                            state: state,
                            mapBuilder: mapBuilder ?? _buildGoogleMap,
                            onPlaceSelected: cubit.selectPlace,
                            onShowList: () =>
                                cubit.changeViewMode(ExplorerViewMode.list),
                            onZoomChanged: cubit.updateZoom,
                            onOpenFilters: () =>
                                _showFilters(context, state, cubit),
                            onChooseCity: onChooseCity,
                          )
                        : ExplorerListContent(
                            state: state,
                            onPlaceSelected: cubit.selectPlaceFromList,
                            onShowMap: () =>
                                cubit.changeViewMode(ExplorerViewMode.map),
                            onChooseCity: onChooseCity,
                            onOpenFilters: () =>
                                _showFilters(context, state, cubit),
                            onListScrollOffsetChanged:
                                cubit.updateListScrollOffset,
                          ),
                  ),
                  if (state.isRefreshing)
                    const Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(
                        key: Key('explorer-filter-refreshing'),
                      ),
                    ),
                ],
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
    ValueChanged<double> onZoomChanged,
  ) => GoogleExplorerMap(
    state: state,
    onPlaceSelected: onPlaceSelected,
    onZoomChanged: onZoomChanged,
  );

  static void _onDestinationSelected(int index, VoidCallback onChooseCity) {
    if (index == 1) onChooseCity();
  }

  static Future<void> _showFilters(
    BuildContext context,
    ExplorerLoaded state,
    ExplorerCubit cubit,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => ExplorerFilterSheet(
      filters: state.filters,
      onCategorySelected: cubit.changeCategory,
      onRadiusSelected: cubit.changeRadius,
      onReset: cubit.resetFilters,
    ),
  );
}
