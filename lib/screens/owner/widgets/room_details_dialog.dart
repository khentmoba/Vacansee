import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/room_model.dart';

/// Dialog for adding or editing room details.
class RoomDetailsDialog extends StatefulWidget {
  final String propertyId;
  final RoomModel? initialRoom;

  const RoomDetailsDialog({
    super.key,
    required this.propertyId,
    this.initialRoom,
  });

  @override
  State<RoomDetailsDialog> createState() => _RoomDetailsDialogState();
}

class _RoomDetailsDialogState extends State<RoomDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _capacityController;
  late final TextEditingController _rateController;
  late final TextEditingController _descriptionController;
  late RoomStatus _status;

  @override
  void initState() {
    super.initState();
    _capacityController = TextEditingController(
      text: widget.initialRoom?.capacity.toString() ?? '1',
    );
    _rateController = TextEditingController(
      text: widget.initialRoom?.monthlyRate?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialRoom?.description ?? '',
    );
    _status = widget.initialRoom?.status ?? RoomStatus.vacant;
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final room = RoomModel(
      roomId: widget.initialRoom?.roomId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: widget.propertyId,
      status: _status,
      capacity: int.parse(_capacityController.text.trim()),
      monthlyRate: int.parse(_rateController.text.trim()),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      lastUpdated: DateTime.now(),
      images: widget.initialRoom?.images ?? [],
    );

    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.initialRoom == null ? 'Add Room' : 'Edit Room'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Monthly Rate
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Rate (₱)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) return 'Enter a valid rate';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity (Persons)',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) return 'Must be at least 1';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<RoomStatus>(
                // ignore: deprecated_member_use
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Current Status',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: RoomStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Brief Description (Optional)',
                  hintText: 'e.g., Near window, Upper bunk...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
