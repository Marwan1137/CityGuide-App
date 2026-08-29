import 'package:city_guide_app/features/favorites/presentation/view_model/favorites_cubit.dart';
import 'package:city_guide_app/features/favorites/presentation/view_model/favorites_state.dart';
import 'package:city_guide_app/features/favorites/presentation/widgets/favorite_card.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/widgets/connectivity_banner.dart';
import 'package:city_guide_app/shared/widgets/navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({required this.onDestinationSelected, super.key});

  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationShell(
    currentIndex: 3,
    onDestinationSelected: onDestinationSelected,
    child: Scaffold(
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final cubit = context.read<FavoritesCubit>();
            return Column(
              children: [
                const ConnectivityBanner(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text('CityGuide', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person_outline, size: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorites',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text('${state.favorites.length} saved places'),
                          ],
                        ),
                      ),
                      const Icon(Icons.search),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: state.categoryFilter == null,
                        onTap: () => cubit.setCategoryFilter(null),
                      ),
                      for (final category in PlaceCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: category.label,
                            selected: state.categoryFilter == category.name,
                            onTap: () => cubit.setCategoryFilter(category.name),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_done_outlined,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Favorites are stored on this device and available offline',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.filtered.isEmpty
                      ? const Center(child: Text('No favorites yet'))
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final favorite = state.filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FavoriteCard(
                          favorite: favorite,
                          onTap: () => context.push(
                            '/place/${favorite.place.id}',
                            extra: favorite.place,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFF0D47A1),
    labelStyle: TextStyle(color: selected ? Colors.white : null),
  );
}