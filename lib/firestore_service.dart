import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reminders';

  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore.collection(_collection).doc(reminder.id).set(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore.collection(_collection).doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<ReminderModel>> getReminders() {
    return _firestore
        .collection(_collection)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(doc.data()))
            .toList());
  }
}
