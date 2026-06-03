import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/destination_model.dart';
import '../theme/app_spacing.dart';
import '../utils/location_geocoder.dart';

/// Demo-friendly map using OpenStreetMap (no Google Cloud billing).
class DestinationMapCard extends StatefulWidget {
  const DestinationMapCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  State<DestinationMapCard> createState() => _DestinationMapCardState();
}

class _DestinationMapCardState extends State<DestinationMapCard> {
  LatLng? _point;
  bool _loading = true;
  bool _usedGeocoder = false;

  @override
  void initState() {
    super.initState();
    _resolvePoint();
  }

  Future<void> _resolvePoint() async {
    final d = widget.destination;
    if (d.hasCoordinates) {
      setState(() {
        _point = LatLng(d.latitude, d.longitude);
        _loading = false;
      });
      return;
    }

    _usedGeocoder = true;
    final latLng = await LocationGeocoder.resolve(d.locationName);
    if (!mounted) return;
    setState(() {
      _point = latLng;
      _loading = false;
    });
  }

  Future<void> _openGoogleMaps() async {
    final point = _point;
    if (point == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinates are missing or invalid.')),
        );
      }
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );
    try {
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final d = widget.destination;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        _LocationPreviewCard(
          destination: d,
          point: _point,
          loading: _loading,
          usedGeocoder: _usedGeocoder,
        ),
        if (_point != null && !_loading) ...[
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _point!,
                  initialZoom: 12,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.travelease',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _point!,
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.location_pin,
                          size: 44,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.tonalIcon(
          onPressed: _loading || _point == null ? null : _openGoogleMaps,
          icon: const Icon(Icons.directions_rounded),
          label: const Text('Open in Google Maps'),
        ),
      ],
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard({
    required this.destination,
    required this.point,
    required this.loading,
    required this.usedGeocoder,
  });

  final DestinationModel destination;
  final LatLng? point;
  final bool loading;
  final bool usedGeocoder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination.locationName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(),
              )
            else if (point != null) ...[
              const SizedBox(height: 10),
              Text(
                'Latitude: ${point!.latitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Longitude: ${point!.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (usedGeocoder)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Coordinates estimated from location name.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
