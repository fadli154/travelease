import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/app_feedback.dart';
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

  Future<void> _onSubmit(DestinationModel model) async {
    setState(() => _isSaving = true);
    try {
      await _service.addDestination(model);
      if (!mounted) return;
      AppFeedback.success(context, 'Destination created successfully');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(
        context,
        AppFeedback.actionError(e, 'Create destination'),
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
