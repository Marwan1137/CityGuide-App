import 'package:city_guide_app/app/routing/app_router.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_cubit.dart';
import 'package:city_guide_app/features/explorer/presentation/view_model/explorer_state.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_filter_sheet.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_list_content.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_map_content.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/explorer_refresh_error_banner.dart';
import 'package:city_guide_app/features/explorer/presentation/widgets/google_explorer_map.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/widgets/friendly_error_view.dart';
import 'package:city_guide_app/shared/widgets/loading_view.dart';
import 'package:city_guide_app/shared/widgets/navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        buildWhen: (previous, current) =>
        previous is! ExplorerLoaded || current is! ExplorerLoaded,
        builder: (context, state) {
          if (state is ExplorerLoading) {
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, index, onChooseCity),
              child: const LoadingView(message: 'Finding nearby cafes…'),
            );
          }
          if (state is ExplorerLoaded) {
            return _LoadedExplorerView(
              onChooseCity: onChooseCity,
              mapBuilder: mapBuilder ?? _buildGoogleMap,
            );
          }
          if (state is ExplorerError) {
            return NavigationShell(
              currentIndex: 0,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, index, onChooseCity),
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
      void Function(GeoPoint target, double zoom) onCameraIdle,
      ) => GoogleExplorerMap(
    state: state,
    onPlaceSelected: onPlaceSelected,
    onCameraIdle: onCameraIdle,
  );

  static void _onDestinationSelected(
      BuildContext context,
      int index,
      VoidCallback onChooseCity,
      ) {
    switch (index) {
      case 1:
        onChooseCity();
      case 2:
        context.go('/add-custom-place');
      case 3:
        context.go(AppRoutes.favorites);
      default:
        break;
    }
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

class _LoadedExplorerView extends StatelessWidget {
  const _LoadedExplorerView({
    required this.onChooseCity,
    required this.mapBuilder,
  });

  final VoidCallback onChooseCity;
  final ExplorerMapBuilder mapBuilder;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExplorerCubit>();
    return NavigationShell(
      currentIndex: 0,
      onDestinationSelected: (index) =>
          ExplorerScreen._onDestinationSelected(context, index, onChooseCity),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: BlocSelector<ExplorerCubit, ExplorerState, ExplorerLoaded?>(
              selector: (state) => state is ExplorerLoaded
                  ? state.copyWith(
                isRefreshing: false,
                refreshErrorMessage: null,
              )
                  : null,
              builder: (context, state) {
                if (state == null) return const SizedBox.shrink();
                return state.viewMode == ExplorerViewMode.map
                    ? ExplorerMapContent(
                  state: state,
                  mapBuilder: mapBuilder,
                  onPlaceSelected: cubit.selectPlace,
                  onShowList: () =>
                      cubit.changeViewMode(ExplorerViewMode.list),
                  onCameraIdle: cubit.onCameraIdle,
                  onSearchThisArea: cubit.searchThisArea,
                  onOpenFilters: () =>
                      ExplorerScreen._showFilters(context, state, cubit),
                  onChooseCity: onChooseCity,
                )
                    : ExplorerListContent(
                  state: state,
                  onPlaceSelected: cubit.selectPlaceFromList,
                  onShowMap: () =>
                      cubit.changeViewMode(ExplorerViewMode.map),
                  onChooseCity: onChooseCity,
                  onOpenFilters: () =>
                      ExplorerScreen._showFilters(context, state, cubit),
                  onListScrollOffsetChanged: cubit.updateListScrollOffset,
                );
              },
            ),
          ),
          BlocSelector<ExplorerCubit, ExplorerState, bool>(
            selector: (state) => state is ExplorerLoaded && state.isRefreshing,
            builder: (context, isRefreshing) => isRefreshing
                ? const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                key: Key('explorer-filter-refreshing'),
              ),
            )
                : const SizedBox.shrink(),
          ),
          BlocSelector<ExplorerCubit, ExplorerState, String?>(
            selector: (state) =>
            state is ExplorerLoaded ? state.refreshErrorMessage : null,
            builder: (context, message) => message == null
                ? const SizedBox.shrink()
                : Align(
              alignment: Alignment.bottomCenter,
              child: ExplorerRefreshErrorBanner(
                message: message,
                onRetry: cubit.retryRefresh,
                onDismiss: cubit.dismissRefreshError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}