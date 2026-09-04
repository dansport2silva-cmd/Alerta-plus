import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Concluídos', icon: Icon(Icons.check_circle)),
              Tab(text: 'Cancelados', icon: Icon(Icons.cancel)),
            ],
          ),
        ),
        body: Consumer<ReminderProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildList(provider.completedReminders, provider),
                _buildList(provider.cancelledReminders, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> reminders, ReminderProvider provider) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nada por aqui',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ReminderCard(
          reminder: reminder,
          onDelete: () => provider.deleteReminder(reminder.id),
        );
      },
    );
  }
}
