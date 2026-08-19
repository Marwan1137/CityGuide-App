import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_cubit.dart';
import 'package:city_guide_app/features/city_search/presentation/view_model/city_search_state.dart';
import 'package:city_guide_app/features/city_search/presentation/widgets/city_result_tile.dart';
import 'package:city_guide_app/shared/widgets/empty_state_view.dart';
import 'package:city_guide_app/shared/widgets/primary_button.dart';
import 'package:city_guide_app/shared/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitySearchContent extends StatefulWidget {
  const CitySearchContent({
    required this.state,
    required this.onRetryDeviceLocation,
    super.key,
  });

  final CitySearchLoaded state;
  final VoidCallback onRetryDeviceLocation;

  @override
  State<CitySearchContent> createState() => _CitySearchContentState();
}

class _CitySearchContentState extends State<CitySearchContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SearchField(
              controller: _controller,
              hintText: 'Search Cairo, القاهرة, Mansoura…',
              onChanged: context.read<CitySearchCubit>().search,
            ),
          ),
          Expanded(
            child: state.isSearchingOnline
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching across Egypt…'),
                      ],
                    ),
                  )
                : _results(context, state),
          ),
        ],
      ),
    );
  }

  Widget _results(BuildContext context, CitySearchLoaded state) {
    if (state.cities.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        children: [
          EmptyStateView(
            title: 'No capital matches “${state.query}”',
            message:
                'Check the spelling or search online for another Egyptian city.',
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Search online for ${state.query}',
            icon: Icons.public,
            expand: true,
            onPressed: state.query.length >= 2
                ? context.read<CitySearchCubit>().searchOnline
                : null,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: widget.onRetryDeviceLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Retry device location'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        if (state.query.isEmpty && state.recentCity != null) ...[
          Text('Recent', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          CityResultTile(
            city: state.recentCity!,
            onTap: () =>
                context.read<CitySearchCubit>().chooseCity(state.recentCity!),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            Text(
              state.query.isEmpty ? 'Governorate capitals' : 'Matches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text('${state.cities.length}'),
          ],
        ),
        const SizedBox(height: 8),
        for (final city in state.cities) ...[
          CityResultTile(
            city: city,
            onTap: () => context.read<CitySearchCubit>().chooseCity(city),
          ),
          const SizedBox(height: 8),
        ],
        TextButton.icon(
          onPressed: widget.onRetryDeviceLocation,
          icon: const Icon(Icons.my_location),
          label: const Text('Use my current location instead'),
        ),
      ],
    );
  }
}
