import 'package:city_guide_app/features/place_details/domain/entity/place_detail.dart';
import 'package:city_guide_app/features/directions/presentation/widgets/directions_button.dart';
import 'package:city_guide_app/features/place_details/presentation/widgets/place_weekly_hours.dart';
import 'package:city_guide_app/shared/domain/geo_point.dart';
import 'package:city_guide_app/shared/domain/place_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

class PlaceDetailsContent extends StatefulWidget {
  const PlaceDetailsContent({
    required this.place,
    required this.placeDetail,
    required this.isLaunchingDirections,
    required this.isFavorite,
    required this.lastDetailUpdatedAt,
    required this.detailErrorMessage,
    required this.onOpenDirections,
    required this.onToggleFavorite,
    required this.onRetryDetail,
    super.key,
  });

  final PlaceSummary place;
  final PlaceDetail? placeDetail;
  final bool isLaunchingDirections;
  final bool isFavorite;
  final DateTime? lastDetailUpdatedAt;
  final String? detailErrorMessage;
  final VoidCallback onOpenDirections;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRetryDetail;

  @override
  State<PlaceDetailsContent> createState() => _PlaceDetailsContentState();
}

class _PlaceDetailsContentState extends State<PlaceDetailsContent> {
  static const _photoHeight = 220.0;
  static const _sheetOverlap = 20.0;

  final _pageController = PageController();
  int _photoIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final detail = widget.placeDetail;
    final photos = detail?.photos ?? const [];
    final priceLabel = _priceLevelLabel(detail?.priceLevel);

    return Column(
      children: [
        const _TopBar(),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _photoHeight,
                child: _PhotoHeader(
                  photos: photos,
                  fallbackPhotoUrl: place.photoUrl,
                  pageController: _pageController,
                  currentIndex: _photoIndex,
                  onPageChanged: (index) => setState(() => _photoIndex = index),
                  isFavorite: widget.isFavorite,
                  onToggleFavorite: widget.onToggleFavorite,
                ),
              ),
              Positioned(
                top: _photoHeight - _sheetOverlap,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          _SelectedCategoryChip(label: place.category.label),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (place.rating case final rating?) ...[
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1)),
                          ],
                          if (priceLabel != null) ...[
                            const SizedBox(width: 12),
                            Text('· $priceLabel'),
                          ],
                          if (place.distanceMeters case final distance?) ...[
                            const SizedBox(width: 12),
                            Text('${(distance / 1000).toStringAsFixed(1)} km away'),
                          ],
                        ],
                      ),
                      if (detail?.openNow != null) ...[
                        const SizedBox(height: 6),
                        _OpenStatusRow(
                          openNow: detail!.openNow!,
                          nextCloseTime: detail.nextCloseTime,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DirectionsButton(
                              isLoading: widget.isLaunchingDirections,
                              onPressed: widget.onOpenDirections,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showComingSoon(context, 'Save'),
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text('Save'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined),
                            tooltip: 'Share',
                            onPressed: () => _sharePlace(place),
                          ),
                        ],
                      ),
                      if (place.address case final address?) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: 'Copy address',
                              onPressed: () => _copyAddress(context, address),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PlaceMapPreview(location: place.location),
                      ],
                      if (detail?.weeklyHours.isNotEmpty ?? false) ...[
                        const Divider(height: 32),
                        PlaceWeeklyHours(weeklyHours: detail!.weeklyHours),
                      ],
                      if (widget.detailErrorMessage != null ||
                          widget.lastDetailUpdatedAt != null) ...[
                        const SizedBox(height: 12),
                        _DetailFreshnessRow(
                          errorMessage: widget.detailErrorMessage,
                          lastUpdatedAt: widget.lastDetailUpdatedAt,
                          onRetry: widget.onRetryDetail,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text('Search', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person_outline, size: 18),
          ),
        ],
      ),
    ),
  );
}

String? _priceLevelLabel(String? priceLevel) => switch (priceLevel) {
  'PRICE_LEVEL_FREE' => 'Free',
  'PRICE_LEVEL_INEXPENSIVE' => r'$',
  'PRICE_LEVEL_MODERATE' => r'$$',
  'PRICE_LEVEL_EXPENSIVE' => r'$$$',
  'PRICE_LEVEL_VERY_EXPENSIVE' => r'$$$$',
  _ => null,
};

String _formatTime(DateTime time) {
  final hour24 = time.hour;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour12:$minute $period';
}

void _copyAddress(BuildContext context, String address) {
  Clipboard.setData(ClipboardData(text: address));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Address copied')));
}

void _sharePlace(PlaceSummary place) {
  final addressLine = place.address != null ? '\n${place.address}' : '';
  SharePlus.instance.share(ShareParams(text: '${place.name}$addressLine'));
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature will be connected in its feature branch.'),
    ),
  );
}

class _OpenStatusRow extends StatelessWidget {
  const _OpenStatusRow({required this.openNow, this.nextCloseTime});

  final bool openNow;
  final DateTime? nextCloseTime;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 10, color: openNow ? Colors.green : Colors.red),
      const SizedBox(width: 6),
      Text(
        openNow ? 'Open now' : 'Closed',
        style: TextStyle(color: openNow ? Colors.green : Colors.red),
      ),
      if (nextCloseTime case final closeTime?) ...[
        const Text(' · Closes '),
        Text(_formatTime(closeTime)),
      ],
    ],
  );
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({
    required this.photos,
    required this.fallbackPhotoUrl,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final List<PlaceDetailPhoto> photos;
  final String? fallbackPhotoUrl;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (photos.isNotEmpty)
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: photos.length,
          itemBuilder: (context, index) => Image.network(
            photos[index].url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.grey.shade300),
          ),
        )
      else if (fallbackPhotoUrl case final photoUrl?)
        Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey.shade300),
        )
      else
        Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.image_outlined, size: 48),
        ),
      if (photos.isNotEmpty) ...[
        Positioned(
          left: 12,
          bottom: 32,
          child: _PhotoBadge(
            label: '${currentIndex + 1}/${photos.length}',
            icon: Icons.photo_camera_outlined,
          ),
        ),
        if (photos[currentIndex].attribution case final attribution?)
          Positioned(
            right: 12,
            bottom: 32,
            child: _PhotoBadge(label: 'Photo by $attribution'),
          ),
      ],
      Positioned(
        top: 12,
        left: 12,
        child: _HeaderIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      Positioned(
        top: 12,
        right: 12,
        child: Row(
          children: [
            _HeaderIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              onPressed: onToggleFavorite,
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.more_vert,
              onPressed: () => _showComingSoon(context, 'More options'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: 0.45),
    shape: const CircleBorder(),
    child: IconButton(
      icon: Icon(icon, color: Colors.white, size: 18),
      iconSize: 18,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
    ),
  );
}

class _PhotoBadge extends StatelessWidget {
  const _PhotoBadge({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
        ],
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}

class _PlaceMapPreview extends StatelessWidget {
  const _PlaceMapPreview({required this.location});

  final GeoPoint location;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: 140,
      child: IgnorePointer(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('place'),
              position: LatLng(location.latitude, location.longitude),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: false,
        ),
      ),
    ),
  );
}
class _DetailFreshnessRow extends StatelessWidget {
  const _DetailFreshnessRow({
    required this.errorMessage,
    required this.lastUpdatedAt,
    required this.onRetry,
  });

  final String? errorMessage;
  final DateTime? lastUpdatedAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Some details couldn\'t be refreshed.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    if (lastUpdatedAt case final updatedAt?) {
      return Text(
        'Last updated ${_relativeTime(updatedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return const SizedBox.shrink();
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
class _SelectedCategoryChip extends StatelessWidget {
  const _SelectedCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF0D47A1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}