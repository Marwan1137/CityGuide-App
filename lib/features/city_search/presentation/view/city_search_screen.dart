import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_state.dart';
import 'package:city_guide_app/features/city_search/presentation/widgets/city_search_content.dart';
import 'package:city_guide_app/shared/domain/search_center.dart';
import 'package:city_guide_app/shared/widgets/friendly_error_view.dart';
import 'package:city_guide_app/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitySearchScreen extends StatelessWidget {
  const CitySearchScreen({
    required this.onRetryDeviceLocation,
    required this.onCenterSelected,
    super.key,
  });

  final VoidCallback onRetryDeviceLocation;
  final ValueChanged<SearchCenter> onCenterSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Choose a city'),
      leading: IconButton(
        tooltip: 'Back to location',
        onPressed: onRetryDeviceLocation,
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: BlocConsumer<CitySearchCubit, CitySearchState>(
      listener: (context, state) {
        if (state case CitySearchLoaded(:final selectedCenter?)) {
          onCenterSelected(selectedCenter);
        }
      },
      builder: (context, state) {
        if (state is CitySearchLoading) {
          return const LoadingView(message: 'Loading Egyptian cities…');
        }
        if (state is CitySearchLoaded) {
          return CitySearchContent(
            state: state,
            onRetryDeviceLocation: onRetryDeviceLocation,
          );
        }
        if (state is CitySearchError) {
          return FriendlyErrorView(
            title: 'City search took a detour',
            message: state.message,
            onRetry: context.read<CitySearchCubit>().retry,
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );
}
