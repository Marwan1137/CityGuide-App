import 'package:city_guide_app/features/city_search/domain/entity/city.dart';
import 'package:flutter/material.dart';

class CityResultTile extends StatelessWidget {
  const CityResultTile({required this.city, required this.onTap, super.key});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          city.isRemoteResult ? Icons.public : Icons.location_city_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        city.bilingualName,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: city.governorateEn.isEmpty
          ? const Text('Online result in Egypt')
          : Text('${city.governorateEn} · ${city.governorateAr}'),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
