import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  late DateTime _eventDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    /// PRE-FILLED DATA
    _titleController = TextEditingController(text: widget.event.title);
    _locationController = TextEditingController(text: widget.event.location);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );

    _eventDate = widget.event.eventDate;
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;

    if (widget.event.imagePath != null) {
      _imageFile = File(widget.event.imagePath!);
    }
  }

  /// DATE PICKER
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  /// TIME PICKER
  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  /// FILE PICKER
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      final updatedEvent = EventModel(
        id: widget.event.id,
        title: _titleController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        eventDate: _eventDate,
        startTime: _startTime,
        endTime: _endTime,
        imagePath: _imageFile?.path,
      );

      Navigator.pop(context, updatedEvent);
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

              /// LOCATION
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              /// DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              /// DATE
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Tanggal: ${_eventDate.day}/${_eventDate.month}/${_eventDate.year}',
                ),
              ),
              const SizedBox(height: 12),

              /// TIME
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(true),
                      child: Text('Mulai: ${_formatTime(_startTime)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(false),
                      child: Text('Selesai: ${_formatTime(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// IMAGE
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Ganti Gambar'),
              ),

              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(
                    _imageFile!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 24),

              /// SAVE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateEvent,
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
