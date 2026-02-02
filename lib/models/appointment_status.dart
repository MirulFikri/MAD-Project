import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String petName;
  final String ownerName;
  final String phone;
  final String type;
  final DateTime date;
  final TimeOfDay time;
  final String reason;
  final String status; // 'Confirmed', 'Pending', 'Urgent'

  Appointment({
    required this.id,
    required this.petName,
    required this.ownerName,
    required this.phone,
    required this.type,
    required this.date,
    required this.time,
    required this.reason,
    this.status = 'Pending',
  });

  // Check if appointment is today
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Format time as HH:MM
  String formatTime() => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
