import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../theme/app_spacing.dart';
import '../cached_destination_image.dart';

class DestinationForm extends StatefulWidget {
  const DestinationForm({
    super.key,
    required this.onSubmit,
    this.initial,
    this.isSaving = false,
  });

  final DestinationModel? initial;
  final bool isSaving;
  final Future<void> Function(DestinationModel model) onSubmit;

  @override
  State<DestinationForm> createState() => _DestinationFormState();
}

class _DestinationFormState extends State<DestinationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _ticketPrice;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _name = TextEditingController(text: d?.name ?? '');
    _location = TextEditingController(text: d?.locationName ?? '');
    _description = TextEditingController(text: d?.description ?? '');
    _category = TextEditingController(text: d?.category ?? '');
    _ticketPrice = TextEditingController(
      text: d != null && d.ticketPrice > 0 ? d.ticketPrice.toStringAsFixed(0) : '',
    );
    _latitude = TextEditingController(
      text: d != null && d.latitude != 0 ? d.latitude.toString() : '',
    );
    _longitude = TextEditingController(
      text: d != null && d.longitude != 0 ? d.longitude.toString() : '',
    );
    _imageUrl = TextEditingController(text: d?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _category.dispose();
    _ticketPrice.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final model = DestinationModel(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      locationName: _location.text.trim(),
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      category: _category.text.trim(),
      ticketPrice: double.tryParse(_ticketPrice.text.trim()) ?? 0,
      latitude: double.tryParse(_latitude.text.trim()) ?? 0,
      longitude: double.tryParse(_longitude.text.trim()) ?? 0,
      averageRating: widget.initial?.averageRating ?? 0,
      totalReviews: widget.initial?.totalReviews ?? 0,
      createdAt: widget.initial?.createdAt,
    );

    await widget.onSubmit(model);
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewSeed = widget.initial?.id ?? _name.text.trim();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, Icons.image_outlined, 'Image'),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: CachedDestinationImage(
                imageUrl: _imageUrl.text,
                imageSeed: previewSeed.isEmpty ? 'preview' : previewSeed,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Leave image URL empty to use a demo photo (Picsum). Firebase Storage is disabled for this demo build.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _imageUrl,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Image URL (optional)',
              hintText: 'https://images.unsplash.com/... or leave empty',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onChanged: (_) => setState(() {}),
          ),
          
          _buildSectionHeader(context, Icons.info_outline, 'Basic Info'),
          TextFormField(
            controller: _name,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Destination name',
              prefixIcon: Icon(Icons.place_outlined),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _category,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _ticketPrice,
            enabled: !widget.isSaving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ticket price (Rp)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          
          _buildSectionHeader(context, Icons.location_on_outlined, 'Location'),
          TextFormField(
            controller: _location,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Location name',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Coordinates (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Used to show the destination on map. If empty, the location name will be geocoded.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitude,
                          enabled: !widget.isSaving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.my_location_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _longitude,
                          enabled: !widget.isSaving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.explore_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          _buildSectionHeader(context, Icons.description_outlined, 'Details'),
          TextFormField(
            controller: _description,
            enabled: !widget.isSaving,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.initial == null ? 'Create destination' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}
