import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/admin/destination_form.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({super.key, this.service});

  final FirebaseService? service;

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  bool _isSaving = false;

  FirebaseService get _service => widget.service ?? FirebaseService();

  Future<void> _onSubmit(DestinationModel model, File? imageFile) async {
    setState(() => _isSaving = true);
    try {
      final id = await _service.addDestination(model);
      if (imageFile != null) {
        final url = await _service.uploadDestinationImage(
          imageFile: imageFile,
          destinationId: id,
        );
        await _service.updateDestinationImageUrl(id, url);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination created')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add destination')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: DestinationForm(
          isSaving: _isSaving,
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}
