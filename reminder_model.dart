import 'package:flutter/material.dart';

enum ReminderCategory {
  work('Trabalho', Icons.work, Color(0xFF6C63FF)),
  personal('Pessoal', Icons.person, Color(0xFF00BFA6)),
  health('Saúde', Icons.favorite, Color(0xFFFF6584)),
  study('Estudos', Icons.school, Color(0xFFFFB800)),
  finance('Financeiro', Icons.attach_money, Color(0xFF4CAF50)),
  other('Outros', Icons.more_horiz, Color(0xFF78909C));

  final String label;
  final IconData icon;
  final Color color;

  const ReminderCategory(this.label, this.icon, this.color);
}

enum ReminderStatus { pending, completed, cancelled }

enum RecurrenceType { none, daily, weekly, monthly }

class ReminderModel {
  final String id;
  final String title;
  final String? description;
  final ReminderCategory category;
  final DateTime dateTime;
  final ReminderStatus status;
  final RecurrenceType recurrence;
  final DateTime createdAt;
  final bool notificationEnabled;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.dateTime,
    this.status = ReminderStatus.pending,
    this.recurrence = RecurrenceType.none,
    required this.createdAt,
    this.notificationEnabled = true,
  });

  bool get isOverdue => dateTime.isBefore(DateTime.now()) && status == ReminderStatus.pending;

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final diff = dateTime.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderCategory? category,
    DateTime? dateTime,
    ReminderStatus? status,
    RecurrenceType? recurrence,
    DateTime? createdAt,
    bool? notificationEnabled,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'recurrence': recurrence.name,
      'createdAt': createdAt.toIso8601String(),
      'notificationEnabled': notificationEnabled,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: ReminderCategory.values.byName(map['category']),
      dateTime: DateTime.parse(map['dateTime']),
      status: ReminderStatus.values.byName(map['status']),
      recurrence: RecurrenceType.values.byName(map['recurrence']),
      createdAt: DateTime.parse(map['createdAt']),
      notificationEnabled: map['notificationEnabled'] ?? true,
    );
  }
}
