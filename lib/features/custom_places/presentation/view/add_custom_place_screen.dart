import 'package:city_guide_app/features/custom_places/presentation/view_model/custom_place_form_cubit.dart';
import 'package:city_guide_app/features/custom_places/presentation/view_model/custom_place_form_state.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_category.dart';
import 'package:city_guide_app/shared/widgets/connectivity_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddCustomPlaceScreen extends StatelessWidget {
  const AddCustomPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<CustomPlaceFormCubit, CustomPlaceFormState>(
        listenWhen: (previous, current) =>
        previous.saved != current.saved || previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.saved) {
            Navigator.of(context).pop();
            return;
          }
          final message = state.errorMessage;
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Add Custom Place')),
          body: const Column(
            children: [
              ConnectivityBanner(),
              Expanded(child: _AddCustomPlaceBody()),
            ],
          ),
        ),
      );
}

class _AddCustomPlaceBody extends StatefulWidget {
  const _AddCustomPlaceBody();

  @override
  State<_AddCustomPlaceBody> createState() => _AddCustomPlaceBodyState();
}

class _AddCustomPlaceBodyState extends State<_AddCustomPlaceBody> {
  late final GoogleMapController _mapControllerCompleter;
  bool _mapReady = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomPlaceFormCubit>();
    final initialLocation = context.select(
          (CustomPlaceFormCubit c) => c.state.location,
    );

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    initialLocation.latitude,
                    initialLocation.longitude,
                  ),
                  zoom: 16,
                ),
                onMapCreated: (controller) => _mapReady = true,
                onCameraMove: (position) => cubit.updateLocation(
                  GeoPoint(
                    latitude: position.target.latitude,
                    longitude: position.target.longitude,
                  ),
                ),
                myLocationButtonEnabled: false,
              ),
              const IgnorePointer(
                child: Icon(Icons.location_on, size: 40, color: Colors.blue),
              ),
            ],
          ),
        ),
        const Flexible(child: _CustomPlaceForm()),
      ],
    );
  }
}

class _CustomPlaceForm extends StatelessWidget {
  const _CustomPlaceForm();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomPlaceFormCubit>();
    return BlocBuilder<CustomPlaceFormCubit, CustomPlaceFormState>(
      builder: (context, state) => Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add custom place',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Location selected on map',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Place name *',
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.setName,
            ),
            const SizedBox(height: 16),
            Text('Category *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PlaceCategory.values
                  .map(
                    (category) => ChoiceChip(
                  label: Text(category.label),
                  selected: state.category == category,
                  onSelected: (_) => cubit.setCategory(category),
                  selectedColor: const Color(0xFF0D47A1),
                  labelStyle: TextStyle(
                    color: state.category == category ? Colors.white : null,
                  ),
                ),
              )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.setAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              onChanged: cubit.setNote,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.canSave ? cubit.save : null,
                child: state.isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}