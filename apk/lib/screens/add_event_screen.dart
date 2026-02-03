import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile;
  String? _imageData;

  /// ======================
  /// SUBMIT TO BACKEND
  /// ======================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final imageData = await _encodeImage();
      await ApiService.addEvent({
        "title": _titleController.text,
        "date": _dateController.text, // yyyy-MM-dd
        "startTime": _startTimeController.text, // HH:mm
        "endTime": _endTimeController.text, // HH:mm
        "image": imageData,
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan event')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ======================
  /// DATE PICKER
  /// ======================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// ======================
  /// TIME PICKER
  /// ======================
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        _imageData = null;
      });
    }
  }

  Future<String?> _encodeImage() async {
    if (_imageFile == null) return null;
    final bytes = await _imageFile!.readAsBytes();
    final base64Data = base64Encode(bytes);
    final ext = _imageFile!.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    return 'data:$mime;base64,$base64Data';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Event'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input(controller: _titleController, label: 'Judul Event'),
              const SizedBox(height: 12),
              _input(
                controller: _dateController,
                label: 'Tanggal',
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _startTimeController,
                label: 'Jam Mulai',
                readOnly: true,
                onTap: () => _pickTime(_startTimeController),
              ),
              const SizedBox(height: 12),
              _input(
                controller: _endTimeController,
                label: 'Jam Selesai',
                readOnly: true,
                onTap: () => _pickTime(_endTimeController),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: (value) =>
          value == null || value.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
