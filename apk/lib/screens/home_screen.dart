import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final List<EventModel> events;

  const HomeScreen({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
          event.imagePath != null
              ? Image.file(
                  File(event.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 60)),
                ),

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
