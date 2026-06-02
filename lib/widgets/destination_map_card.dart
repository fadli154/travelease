import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_spacing.dart';
import '../utils/location_geocoder.dart';

class DestinationMapCard extends StatefulWidget {
  const DestinationMapCard({
    super.key,
    required this.location,
    required this.placeName,
  });

  final String location;
  final String placeName;

  @override
  State<DestinationMapCard> createState() => _DestinationMapCardState();
}

class _DestinationMapCardState extends State<DestinationMapCard> {
  late Future<LatLng> _coordinatesFuture;

  @override
  void initState() {
    super.initState();
    _coordinatesFuture = LocationGeocoder.resolve(widget.location);
  }

  @override
  void didUpdateWidget(DestinationMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _coordinatesFuture = LocationGeocoder.resolve(widget.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.location,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: FutureBuilder<LatLng>(
              future: _coordinatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final point = snapshot.data ?? LocationGeocoder.indonesiaCenter;

                return FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 11,
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
                          point: point,
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.location_pin,
                            size: 48,
                            color: colorScheme.primary,
                            shadows: const [
                              Shadow(blurRadius: 8, color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
