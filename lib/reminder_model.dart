import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderCategory { estudos, tarefas, compromissos }

enum ReminderStatus { pendente, concluido, cancelado }

enum RecurrenceType { nenhuma, diario, semanal, mensal }

class ReminderModel {
  final String id;
  final String title;
  final ReminderCategory category;
  final DateTime dateTime;
  final ReminderStatus status;
  final RecurrenceType recurrence;
  final DateTime createdAt;
  final int? notificationId;

  ReminderModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    this.status = ReminderStatus.pendente,
    this.recurrence = RecurrenceType.nenhuma,
    required this.createdAt,
    this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status.name,
      'recurrence': recurrence.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationId': notificationId,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: ReminderCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ReminderCategory.tarefas,
      ),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReminderStatus.pendente,
      ),
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.name == map['recurrence'],
        orElse: () => RecurrenceType.nenhuma,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notificationId: map['notificationId'],
    );
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    ReminderCategory? category,
    DateTime? dateTime,
    ReminderStatus? status,
    RecurrenceType? recurrence,
    DateTime? createdAt,
    int? notificationId,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  String get categoryLabel {
    switch (category) {
      case ReminderCategory.estudos:
        return '📚 Estudos';
      case ReminderCategory.tarefas:
        return '📝 Tarefas';
      case ReminderCategory.compromissos:
        return '📅 Compromissos';
    }
  }

  String get recurrenceLabel {
    switch (recurrence) {
      case RecurrenceType.nenhuma:
        return 'Único';
      case RecurrenceType.diario:
        return '🔄 Diário';
      case RecurrenceType.semanal:
        return '🔄 Semanal';
      case RecurrenceType.mensal:
        return '🔄 Mensal';
    }
  }

  Color get categoryColor {
    switch (category) {
      case ReminderCategory.estudos:
        return const Color(0xFF4F46E5);
      case ReminderCategory.tarefas:
        return const Color(0xFFEA580C);
      case ReminderCategory.compromissos:
        return const Color(0xFF059669);
    }
  }

  Color get categoryBgColor {
    switch (category) {
      case ReminderCategory.estudos:
        return const Color(0xFFEEF2FF);
      case ReminderCategory.tarefas:
        return const Color(0xFFFFF7ED);
      case ReminderCategory.compromissos:
        return const Color(0xFFECFDF5);
    }
  }
}
