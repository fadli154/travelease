import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/admin/destination_form.dart';

class EditDestinationScreen extends StatefulWidget {
  const EditDestinationScreen({
    super.key,
    required this.destination,
    this.service,
  });

  final DestinationModel destination;
  final FirebaseService? service;

  @override
  State<EditDestinationScreen> createState() => _EditDestinationScreenState();
}

class _EditDestinationScreenState extends State<EditDestinationScreen> {
  bool _isSaving = false;

  FirebaseService get _service => widget.service ?? FirebaseService();

  Future<void> _onSubmit(DestinationModel model, File? imageFile) async {
    setState(() => _isSaving = true);
    try {
      var updated = model.copyWith(id: widget.destination.id);
      if (imageFile != null) {
        final url = await _service.uploadDestinationImage(
          imageFile: imageFile,
          destinationId: widget.destination.id,
        );
        updated = updated.copyWith(imageUrl: url);
      }
      await _service.updateDestination(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination updated')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit destination')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: DestinationForm(
          initial: widget.destination,
          isSaving: _isSaving,
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}
