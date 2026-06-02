import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final Future<void> Function(
    DestinationModel model,
    File? imageFile,
  ) onSubmit;

  @override
  State<DestinationForm> createState() => _DestinationFormState();
}

class _DestinationFormState extends State<DestinationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _rating;
  late final TextEditingController _ticketPrice;
  File? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _name = TextEditingController(text: d?.name ?? '');
    _location = TextEditingController(text: d?.location ?? '');
    _description = TextEditingController(text: d?.description ?? '');
    _category = TextEditingController(text: d?.category ?? '');
    _rating = TextEditingController(
      text: d != null ? d.rating.toString() : '4.5',
    );
    _ticketPrice = TextEditingController(
      text: d != null && d.ticketPrice > 0 ? d.ticketPrice.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _category.dispose();
    _rating.dispose();
    _ticketPrice.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final model = DestinationModel(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      location: _location.text.trim(),
      description: _description.text.trim(),
      imageUrl: widget.initial?.imageUrl ?? '',
      rating: double.tryParse(_rating.text.trim()) ?? 0,
      category: _category.text.trim(),
      ticketPrice: double.tryParse(_ticketPrice.text.trim()) ?? 0,
      createdAt: widget.initial?.createdAt,
    );

    await widget.onSubmit(model, _pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = widget.initial?.imageUrl ?? '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: widget.isSaving ? null : _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                    : existingUrl.isNotEmpty
                        ? CachedDestinationImage(imageUrl: existingUrl)
                        : ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                const Text('Tap to upload image'),
                              ],
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _name,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Destination name',
              prefixIcon: Icon(Icons.place_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _location,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Location is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _category,
            enabled: !widget.isSaving,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Category is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rating,
                  enabled: !widget.isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                    prefixIcon: Icon(Icons.star_outline_rounded),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0 || n > 5) {
                      return 'Rating 0–5';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _ticketPrice,
                  enabled: !widget.isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ticket (Rp)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _description,
            enabled: !widget.isSaving,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Description is required' : null,
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
