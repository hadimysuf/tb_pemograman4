# Event Organizer (Flutter)

## Deskripsi
Aplikasi Flutter ini dipakai untuk mengelola event pribadi. Alur utamanya:
register / login -> dapat token -> CRUD event -> lihat status event.
Semua data event disimpan di backend (Node + SQLite) dan diakses lewat API.

## Fitur Utama (Ringkas)
- Auth (register, login, logout)
- Home dashboard (ringkasan & daftar event + gambar)
- Event CRUD (tambah, edit, hapus)
- Profile (lihat & edit profil, ganti password)

## Kode Lengkap per File (lib/)

### lib/main.dart
`dart
import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';
import 'screens/landing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Organizer',
      theme: AppTheme.lightTheme(),
      home: const LandingScreen(),
    );
  }
}

`

### lib/models/event_model.dart
`dart
import 'package:flutter/material.dart';

class EventModel {
  final int id;
  final String title;
  final String location;
  final String description;

  /// Tanggal event (1 hari)
  final DateTime eventDate;

  /// Jam mulai & selesai
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  /// Path gambar (opsional)
  final String? imagePath;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.imagePath,
  });

  // ==================================================
  // FROM JSON (BACKEND → UI MODEL)
  // ==================================================
  factory EventModel.fromJson(Map<String, dynamic> json) {
    // parse tanggal
    final date = DateTime.parse(json['date']);

    // parse jam (HH:mm)
    TimeOfDay parseTime(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return EventModel(
      id: json['id'],
      title: json['title'],
      location: json['location'] ?? '-',
      description: json['description'] ?? '',
      eventDate: date,
      startTime: parseTime(json['startTime']),
      endTime: parseTime(json['endTime']),
      imagePath: json['image'],
    );
  }

  /// =========================
  /// STATUS EVENT (DINAMIS)
  /// =========================
  String getStatus(DateTime now) {
    final startDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (now.isBefore(startDateTime)) {
      return 'Belum Dimulai';
    } else if (now.isAfter(endDateTime)) {
      return 'Selesai';
    } else {
      return 'Sedang Berlangsung';
    }
  }

  /// =========================
  /// FORMAT JAM UNTUK UI
  /// =========================
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// =========================
  /// RANGE JAM (UI)
  /// =========================
  String get timeRange {
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}

`

### lib/screens/add_event_screen.dart
`dart
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

`

### lib/screens/edit_event_screen.dart
`dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/image_utils.dart';

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
  File? _imageFile;
  String? _imageData;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event.title);
    _dateController = TextEditingController(
      text:
          "${widget.event.eventDate.year}-${widget.event.eventDate.month.toString().padLeft(2, '0')}-${widget.event.eventDate.day.toString().padLeft(2, '0')}",
    );
    _startTimeController = TextEditingController(
      text: widget.event.formatTime(widget.event.startTime),
    );
    _endTimeController = TextEditingController(
      text: widget.event.formatTime(widget.event.endTime),
    );
    _imageData = widget.event.imagePath;
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _encodeImage() async {
    if (_imageFile == null) return _imageData;
    final bytes = await _imageFile!.readAsBytes();
    final base64Data = base64Encode(bytes);
    final ext = _imageFile!.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    return 'data:$mime;base64,$base64Data';
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final imageData = await _encodeImage();
      await ApiService.updateEvent(widget.event.id, {
        "title": _titleController.text,
        "date": _dateController.text,
        "startTime": _startTimeController.text,
        "endTime": _endTimeController.text,
        "image": imageData,
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
              const SizedBox(height: 20),

              /// DATE
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('Tanggal: ${_dateController.text}'),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Ganti Gambar'),
              ),
              if (_imageFile != null || (_imageData != null && _imageData!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : buildEventImage(_imageData, height: 150),
                ),

              const SizedBox(height: 28),

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

`

### lib/screens/event_detail_screen.dart
`dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/image_utils.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDelete;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onDelete,
  });

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Yakin ingin menghapus event ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ApiService.deleteEvent(event.id);
    onDelete();
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditEventScreen(event: event),
                ),
              );

              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildEventImage(event.imagePath, height: 180),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text("Tanggal: ${event.eventDate}"),
            const SizedBox(height: 8),
            Text("Waktu: ${event.timeRange}"),
          ],
        ),
      ),
    );
  }
}

`

### lib/screens/event_screen.dart
`dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/image_utils.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, required List<EventModel> events});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<List<EventModel>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _fetchEvents();
  }

  /// =========================
  /// FETCH EVENTS FROM BACKEND
  /// =========================
  Future<List<EventModel>> _fetchEvents() async {
    final response = await ApiService.getEvents();

    final List data = response.data;

    return data.map((json) {
      final start = json['startTime'].toString().split(':');
      final end = json['endTime'].toString().split(':');

      return EventModel(
        id: json['id'],
        title: json['title'],
        location: '-',
        description: '-',
        eventDate: DateTime.parse(json['date']),
        startTime: TimeOfDay(
          hour: int.parse(start[0]),
          minute: int.parse(start[1]),
        ),
        endTime: TimeOfDay(hour: int.parse(end[0]), minute: int.parse(end[1])),
        imagePath: json['image'],
      );
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Belum Dimulai':
        return Colors.orange;
      case 'Sedang Berlangsung':
        return Colors.green;
      case 'Selesai':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        automaticallyImplyLeading: false,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Event'),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          );

          if (result == true) {
            setState(() {
              _futureEvents = _fetchEvents();
            });
          }
        },
      ),

      body: FutureBuilder<List<EventModel>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data!;

          if (events.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final status = event.getStatus(DateTime.now());
              final statusColor = _statusColor(status);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventDetailScreen(event: event, onDelete: () {}),
                      ),
                    );

                    setState(() {
                      _futureEvents = _fetchEvents();
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEventImage(event.imagePath, height: 150),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 6),
                                Text(event.timeRange),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(status),
                                  backgroundColor:
                                      statusColor.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ================= EMPTY STATE =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_note, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Belum ada event',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            'Tekan tombol tambah untuk membuat event',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

`

### lib/screens/home_screen.dart
`dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/image_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<EventModel>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _fetchEvents();
  }

  Future<List<EventModel>> _fetchEvents() async {
    final response = await ApiService.getEvents();
    final List data = response.data;

    return data.map((json) {
      final start = json['startTime'].toString().split(':');
      final end = json['endTime'].toString().split(':');

      return EventModel(
        id: json['id'],
        title: json['title'],
        location: json['location'] ?? '-',
        description: json['description'] ?? '',
        eventDate: DateTime.parse(json['date']),
        startTime: TimeOfDay(
          hour: int.parse(start[0]),
          minute: int.parse(start[1]),
        ),
        endTime: TimeOfDay(hour: int.parse(end[0]), minute: int.parse(end[1])),
        imagePath: json['image'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        automaticallyImplyLeading: false,
        title: const Text('Home Dashboard'),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          final now = DateTime.now();

          final allEvents = [...events]
            ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

          final ongoingEvents = allEvents
              .where((e) => e.getStatus(now) == 'Sedang Berlangsung')
              .toList();

          final upcomingEvents = allEvents
              .where((e) => e.getStatus(now) == 'Belum Dimulai')
              .take(3)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= GREETING CARD =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola semua event kamu di sini',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= SUMMARY =================
                Row(
                  children: [
                    _summaryCard(
                      title: 'Total Event',
                      value: events.length.toString(),
                      icon: Icons.event,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _summaryCard(
                      title: 'Sedang Berlangsung',
                      value: ongoingEvents.length.toString(),
                      icon: Icons.play_circle_fill,
                      color: AppTheme.primaryDark,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// ================= ONGOING EVENTS =================
                _sectionTitle('Sedang Berlangsung'),
                if (ongoingEvents.isEmpty)
                  _emptyText('Tidak ada event yang sedang berlangsung')
                else
                  Column(
                    children: ongoingEvents.map((event) {
                      return _eventCard(event, now);
                    }).toList(),
                  ),

                const SizedBox(height: 32),

                /// ================= UPCOMING EVENTS =================
                _sectionTitle('Event Terdekat'),
                if (upcomingEvents.isEmpty)
                  _emptyText('Tidak ada event terdekat')
                else
                  Column(
                    children: upcomingEvents.map((event) {
                      return _eventCard(event, now);
                    }).toList(),
                  ),

                const SizedBox(height: 32),

                /// ================= ALL EVENTS =================
                _sectionTitle('Semua Event'),
                if (allEvents.isEmpty)
                  _emptyText('Belum ada event')
                else
                  Column(
                    children: allEvents.map((event) {
                      return _eventCard(event, now);
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= COMPONENT =================

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard(EventModel event, DateTime now) {
    final status = event.getStatus(now);

    Color statusColor;
    if (status == 'Sedang Berlangsung') {
      statusColor = Colors.green;
    } else if (status == 'Belum Dimulai') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          buildEventImage(event.imagePath, height: 160, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 6),
                    Text(event.timeRange),
                  ],
                ),
                const SizedBox(height: 10),
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

`

### lib/screens/landing_screen.dart
`dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../utils/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/landing_page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDark.withOpacity(0.75),
                AppTheme.primary.withOpacity(0.55),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event Organizer App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi untuk mengelola event dengan mudah. '
                'Pengguna dapat menambahkan, mengubah, dan menghapus event '
                'serta melihat status event secara otomatis.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Fitur utama:\n'
                '• Login & Register\n'
                '• CRUD Event\n'
                '• Status Event Otomatis\n'
                '• Upload Gambar Event',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Register'),
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

`

### lib/screens/login_screen.dart
`dart
import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool hasUppercase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavbar()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login gagal')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ================= ICON =================
                      const Icon(
                        Icons.event_available,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Masuk untuk mengelola event',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),

                      const SizedBox(height: 24),

                      /// ================= EMAIL =================
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!isValidEmail(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ================= PASSWORD =================
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          if (!hasUppercase(value)) {
                            return 'Password harus mengandung huruf kapital';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('LOGIN'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ================= REGISTER =================
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Belum punya akun? Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

`

### lib/screens/profile_screen.dart
`dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Hadi M Yusuf';
  String email = 'hadi@email.com';
  String npm = '714230019';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getProfile();
    if (!mounted) return;
    if (data != null) {
      setState(() {
        name = data['name'] ?? name;
        email = data['email'] ?? email;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// ================= HEADER =================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppTheme.primarySoft,
                          child: const Icon(
                            Icons.person,
                            size: 42,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ================= INFO CARD =================
                  _infoTile('Nama', name),
                  _infoTile('Email', email),
                  _infoTile('NPM', npm),

                  const SizedBox(height: 24),

                  /// ================= ACTION =================
                  _primaryButton(
                    icon: Icons.edit,
                    label: 'Edit Profil',
                    onTap: _editProfile,
                  ),

                  const SizedBox(height: 12),

                  _outlineButton(
                    icon: Icons.lock,
                    label: 'Ganti Password',
                    onTap: _changePassword,
                  ),

                  const SizedBox(height: 12),

                  _dangerButton(icon: Icons.logout, label: 'Logout', onTap: _logout),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// ================= COMPONENT =================

  Widget _infoTile(String label, String value) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dangerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.red),
      label: Text(label, style: const TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// ================= ACTION =================

  void _editProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newEmail = emailController.text.trim();
              if (newName.isEmpty || newEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama dan email wajib diisi')),
                );
                return;
              }

              final ok = await ApiService.updateProfile(newName, newEmail);
              if (!context.mounted) return;

              if (ok) {
                setState(() {
                  name = newName;
                  email = newEmail;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diupdate')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal update profil')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Password'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldPassController.text.isEmpty ||
                  newPassController.text.isEmpty ||
                  confirmPassController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field wajib diisi')),
                );
                return;
              }
              if (newPassController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru minimal 8 karakter'),
                  ),
                );
                return;
              }
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Konfirmasi password tidak sama')),
                );
                return;
              }

              final ok = await ApiService.changePassword(
                oldPassController.text,
                newPassController.text,
              );

              if (!context.mounted) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Password berhasil diubah' : 'Gagal mengubah password',
                  ),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                hintText: 'Minimal 8 karakter',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
`

### lib/screens/register_screen.dart
`dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isSubmitting = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool hasUppercase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  Future<void> handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final success = await ApiService.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal')),
        );
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ================= ICON =================
                      const Icon(
                        Icons.person_add,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Register',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Buat akun baru untuk mulai',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),

                      const SizedBox(height: 24),

                      /// ================= NAMA =================
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ================= EMAIL =================
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!isValidEmail(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ================= PASSWORD =================
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          if (!hasUppercase(value)) {
                            return 'Password harus mengandung huruf kapital';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : handleRegister,
                          child: Text(_isSubmitting ? 'Mendaftarkan...' : 'REGISTER'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ================= BACK TO LOGIN =================
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Sudah punya akun? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

`

### lib/services/api_service.dart
`dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// =========================
  /// AUTH - LOGIN
  /// =========================
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _saveToken(token);
          _dio.options.headers['Authorization'] = 'Bearer $token';
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// =========================
  /// AUTH - REGISTER
  /// =========================
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// =========================
  /// LOAD TOKEN (AUTO LOGIN)
  /// =========================
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _dio.options.headers.remove('Authorization');
  }

  /// =========================
  /// CHANGE PASSWORD
  /// =========================
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _dio.put(
        '/users/me/password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// =========================
  /// PROFILE
  /// =========================
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile(String name, String email) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: {'name': name, 'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// =========================
  /// EVENTS
  /// =========================
  static Future<Response> getEvents() async {
    return await _dio.get('/events');
  }

  static Future<Response> addEvent(Map<String, dynamic> data) async {
    return await _dio.post('/events', data: data);
  }

  static Future<Response> updateEvent(int id, Map<String, dynamic> data) async {
    return await _dio.put('/events/$id', data: data);
  }

  static Future<Response> deleteEvent(int id) async {
    return await _dio.delete('/events/$id');
  }
}

`

### lib/utils/app_config.dart
`dart
class AppConfig {
  // Production base URL
  static const String baseUrl = 'https://eo.sadap.io/api';
}

`

### lib/utils/app_theme.dart
`dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primarySoft = Color(0xFFEFF4FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    final baseTextTheme = Typography.blackCupertino;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: primarySoft,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textPrimary,
        displayColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary),
        ),
        prefixIconColor: primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
      ),
    );
  }
}

`

### lib/utils/image_utils.dart
`dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

bool isDataImage(String? value) {
  return value != null && value.startsWith('data:image');
}

Uint8List? decodeDataImage(String data) {
  if (!isDataImage(data)) {
    return null;
  }

  final base64Part = data.split(',').last;
  return base64Decode(base64Part);
}

Widget buildEventImage(
  String? imageData, {
  double height = 180,
  BoxFit fit = BoxFit.cover,
}) {
  if (imageData == null || imageData.isEmpty) {
    return Container(
      height: height,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image, size: 60)),
    );
  }

  if (isDataImage(imageData)) {
    final bytes = decodeDataImage(imageData);
    if (bytes != null) {
      return Image.memory(
        bytes,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }
  }

  return Image.file(
    File(imageData),
    height: height,
    width: double.infinity,
    fit: fit,
  );
}

`

### lib/widgets/bottom_navbar.dart
`dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../screens/home_screen.dart';
import '../screens/event_screen.dart';
import '../screens/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      EventScreen(events: const []),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

`

## Konfigurasi API
Base URL API diset di:
`
lib/utils/app_config.dart
`

## Catatan Teknis
- Gambar event dikirim sebagai **Base64** di field image.
- Backend harus menerima payload besar (limit body dinaikkan).