import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  ReminderCategory _selectedCategory = ReminderCategory.estudos;
  ReminderCategory get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setCategory(ReminderCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addReminder({
    required String title,
    required DateTime dateTime,
    required ReminderCategory category,
    RecurrenceType recurrence = RecurrenceType.nenhuma,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Agendar notificação local
      final notificationId = await _notifications.scheduleNotification(
        title: title,
        body: '⏰ Hora do seu lembrete: $title',
        scheduledDate: dateTime,
        category: category,
      );

      final reminder = ReminderModel(
        id: id,
        title: title,
        category: category,
        dateTime: dateTime,
        recurrence: recurrence,
        createdAt: DateTime.now(),
        notificationId: notificationId > 0 ? notificationId : null,
      );

      await _firestore.createReminder(reminder);
      _reminders.add(reminder);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao criar lembrete: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelReminder(String id, int? notificationId) async {
    try {
      if (notificationId != null) {
        await _notifications.cancelNotification(notificationId);
      }
      await _firestore.cancelReminder(id);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = _reminders[index].copyWith(status: ReminderStatus.cancelado);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao cancelar: $e';
      notifyListeners();
    }
  }

  Future<void> completeReminder(String id) async {
    try {
      await _firestore.markAsCompleted(id);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = _reminders[index].copyWith(status: ReminderStatus.concluido);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao concluir: $e';
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _firestore.deleteReminder(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar: $e';
      notifyListeners();
    }
  }

  List<ReminderModel> getRemindersByFilter(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    switch (filter) {
      case 'Hoje':
        return _reminders.where((r) {
          final d = r.dateTime;
          return d.year == today.year && d.month == today.month && d.day == today.day;
        }).toList();
      case 'Semana':
        return _reminders.where((r) {
          return r.dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
              r.dateTime.isBefore(weekEnd);
        }).toList();
      default:
        return _reminders.where((r) => r.status == ReminderStatus.pendente).toList();
    }
  }

  Future<void> testNotification() async {
    await _notifications.showTestNotification();
  }
}
