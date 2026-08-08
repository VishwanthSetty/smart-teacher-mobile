import 'package:flutter/foundation.dart';

/// An immutable representation of a teaching class/section.
@immutable
class ClassModel {
  const ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.grade,
    required this.studentCount,
    required this.room,
    required this.schedule,
  });

  final String id;
  final String name;
  final String subject;
  final String grade;
  final int studentCount;
  final String room;

  /// Human-readable meeting time, e.g. "Mon, Wed · 09:00 AM".
  final String schedule;

  ClassModel copyWith({
    String? name,
    String? subject,
    String? grade,
    int? studentCount,
    String? room,
    String? schedule,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      studentCount: studentCount ?? this.studentCount,
      room: room ?? this.room,
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ClassModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
