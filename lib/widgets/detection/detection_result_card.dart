import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/detection/landmark_food_model.dart';

class DetectionResultCard extends StatelessWidget {
  final LandmarkFoodInfo info;
  final double confidence;
  final bool voiceEnabled;
  final VoidCallback onVoiceToggle;
  final double sensitivity;
  final ValueChanged<double> onSensitivityChanged;

  const DetectionResultCard({
    super.key,
    required this.info,
    required this.confidence,
    required this.voiceEnabled,
    required this.onVoiceToggle,
    required this.sensitivity,
    required this.onSensitivityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isFood = info.category.toLowerCase() == 'food';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Category Badge & Confidence
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFood
                          ? Colors.orangeAccent.withValues(alpha: 0.25)
                          : Colors.tealAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFood ? Colors.orangeAccent : Colors.tealAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFood ? Icons.restaurant_menu_rounded : Icons.landscape_rounded,
                          color: isFood ? Colors.orangeAccent : Colors.tealAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isFood ? l10n.foodInfo : l10n.landmarkInfo,
                          style: TextStyle(
                            color: isFood ? Colors.orangeAccent : Colors.tealAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.confidence}: ${(confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title Name
              Text(
                info.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Location / Origin Row
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isFood ? l10n.originLabel : l10n.locationLabel}: ${info.origin}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                info.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xDDFFFFFF),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const Divider(color: Colors.white12, height: 24, thickness: 1),

              // Bottom control elements: Voice Toggle & Sensitivity Slider
              Row(
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: voiceEnabled
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                      foregroundColor: voiceEnabled
                          ? theme.colorScheme.primaryContainer
                          : Colors.white70,
                    ),
                    onPressed: onVoiceToggle,
                    icon: Icon(
                      voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.sensitivityLabel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              sensitivity.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveTrackColor: Colors.white10,
                            thumbColor: theme.colorScheme.primary,
                            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: sensitivity,
                            min: 0.2,
                            max: 0.9,
                            onChanged: onSensitivityChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
