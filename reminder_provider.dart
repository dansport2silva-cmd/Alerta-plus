import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  List<ReminderModel> get pendingReminders =>
      _reminders.where((r) => r.status == ReminderStatus.pending).toList();

  List<ReminderModel> get todayReminders =>
      pendingReminders.where((r) => r.isToday).toList();

  List<ReminderModel> get weekReminders =>
      pendingReminders.where((r) => r.isThisWeek).toList();

  List<ReminderModel> get completedReminders =>
      _reminders.where((r) => r.status == ReminderStatus.completed).toList();

  List<ReminderModel> get cancelledReminders =>
      _reminders.where((r) => r.status == ReminderStatus.cancelled).toList();

  ReminderProvider() {
    _firestore.getReminders().listen((reminders) {
      _reminders = reminders;
      notifyListeners();
    });
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore.addReminder(reminder);
    await _notifications.scheduleNotification(reminder);
  }

  Future<void> completeReminder(ReminderModel reminder) async {
    final updated = reminder.copyWith(status: ReminderStatus.completed);
    await _firestore.updateReminder(updated);
    await _notifications.cancelNotification(reminder.id);
  }

  Future<void> cancelReminder(ReminderModel reminder) async {
    final updated = reminder.copyWith(status: ReminderStatus.cancelled);
    await _firestore.updateReminder(updated);
    await _notifications.cancelNotification(reminder.id);
  }

  Future<void> deleteReminder(String id) async {
    await _firestore.deleteReminder(id);
    await _notifications.cancelNotification(id);
  }
}
