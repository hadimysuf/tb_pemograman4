import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
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
                  child: Padding(
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
                              backgroundColor: statusColor.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
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
