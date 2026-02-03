import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event.title);
    _dateController = TextEditingController(
      text:
          "${widget.event.eventDate.year}-${widget.event.eventDate.month.toString().padLeft(2, '0')}-${widget.event.eventDate.day.toString().padLeft(2, '0')}",
    );
    _startTimeController = TextEditingController(text: widget.event.formatTime(widget.event.startTime));
    _endTimeController = TextEditingController(text: widget.event.formatTime(widget.event.endTime));
  }

  /// DATE PICKER
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.event.eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      _dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// TIME PICKER
  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.updateEvent(widget.event.id, {
        "title": _titleController.text,
        "date": _dateController.text,
        "startTime": _startTimeController.text,
        "endTime": _endTimeController.text,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal update event')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// TITLE
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Event',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              /// DATE
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('Tanggal: ${_dateController.text}'),
              ),
              const SizedBox(height: 12),

              /// TIME
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(_startTimeController),
                      child: Text('Mulai: ${_startTimeController.text}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(_endTimeController),
                      child: Text('Selesai: ${_endTimeController.text}'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SAVE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateEvent,
                  child: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
