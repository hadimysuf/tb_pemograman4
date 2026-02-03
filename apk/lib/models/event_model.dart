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
