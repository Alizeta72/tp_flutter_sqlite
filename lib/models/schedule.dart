import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final int courseId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room;

  Schedule({
    this.id,
    required this.courseId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
  });
}
