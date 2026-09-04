import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../widgets/gradient_button.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  ReminderCategory _category = ReminderCategory.personal;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  RecurrenceType _recurrence = RecurrenceType.none;
  bool _notificationEnabled = true;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _saveReminder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um título para o lembrete')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _category,
      dateTime: dateTime,
      recurrence: _recurrence,
      createdAt: DateTime.now(),
      notificationEnabled: _notificationEnabled,
    );

    context.read<ReminderProvider>().addReminder(reminder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lembrete'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Reunião com equipe',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Detalhes do lembrete...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ReminderCategory.values.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  avatar: Icon(cat.icon, size: 18, color: isSelected ? Colors.white : cat.color),
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: cat.color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Data e Hora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                          const SizedBox(width: 12),
                          Text(dateFormat.format(_selectedDate)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                          const SizedBox(width: 12),
                          Text(_selectedTime.format(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Recorrência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SegmentedButton<RecurrenceType>(
              segments: const [
                ButtonSegment(value: RecurrenceType.none, label: Text('Nenhuma')),
                ButtonSegment(value: RecurrenceType.daily, label: Text('Diária')),
                ButtonSegment(value: RecurrenceType.weekly, label: Text('Semanal')),
                ButtonSegment(value: RecurrenceType.monthly, label: Text('Mensal')),
              ],
              selected: {_recurrence},
              onSelectionChanged: (set) => setState(() => _recurrence = set.first),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Ativar notificação'),
              subtitle: const Text('Receber alerta no horário definido'),
              value: _notificationEnabled,
              onChanged: (v) => setState(() => _notificationEnabled = v),
              activeColor: const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Salvar Lembrete',
              onPressed: _saveReminder,
            ),
          ],
        ),
      ),
    );
  }
}
