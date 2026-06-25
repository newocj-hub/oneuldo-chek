import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../utils/notification_service.dart';
import '../utils/theme_provider.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _cycleController;
  late String _selectedIcon;
  late List<bool> _selectedDays;
  late bool _useSaving;
  late bool _useAlarm;
  late TimeOfDay _alarmTime;

  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _icons = [
    '🚬',
    '☕',
    '🍺',
    '🛍️',
    '🚗',
    '🍔',
    '🎮',
    '📱',
    '🍕',
    '🧋',
    '💊',
    '🚶',
    '🎯',
    '🌿',
    '🏊',
    '🚴',
    '🍵',
    '📝',
    '🎸',
    '💧',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedIcon = widget.habit.icon;
    _selectedDays = List.generate(
      7,
      (i) => widget.habit.repeatDays.contains(i),
    );
    _useSaving = widget.habit.savingAmount > 0;
    _useAlarm = widget.habit.alarmTime != null;
    _amountController = TextEditingController(
      text: widget.habit.savingAmount > 0 ? '${widget.habit.savingAmount}' : '',
    );
    _cycleController = TextEditingController(
      text: '${widget.habit.savingCycle}',
    );
    if (widget.habit.alarmTime != null) {
      final parts = widget.habit.alarmTime!.split(':');
      _alarmTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      _alarmTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  void _selectAll() => setState(() {
    for (int i = 0; i < 7; i++) _selectedDays[i] = true;
  });

  void _selectWeekdays() => setState(() {
    for (int i = 0; i < 7; i++) _selectedDays[i] = i < 5;
  });

  void _selectWeekends() => setState(() {
    for (int i = 0; i < 7; i++) _selectedDays[i] = i >= 5;
  });

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _alarmTime = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('습관 이름을 입력해주세요!')));
      return;
    }
    final days = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) days.add(i);
    }
    if (days.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('반복 요일을 하나 이상 선택해주세요!')));
      return;
    }

    widget.habit.name = _nameController.text.trim();
    widget.habit.icon = _selectedIcon;
    widget.habit.repeatDays = days;

    if (_useSaving) {
      widget.habit.savingAmount =
          int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      widget.habit.savingCycle = int.tryParse(_cycleController.text) ?? 1;
    } else {
      widget.habit.savingAmount = 0;
      widget.habit.savingCycle = 1;
    }

    if (_useAlarm) {
      widget.habit.alarmTime =
          '${_alarmTime.hour.toString().padLeft(2, '0')}:${_alarmTime.minute.toString().padLeft(2, '0')}';
      await NotificationService().scheduleHabitNotification(
        id: widget.habit.key as int,
        habitName: widget.habit.name,
        icon: widget.habit.icon,
        hour: _alarmTime.hour,
        minute: _alarmTime.minute,
        repeatDays: days,
      );
    } else {
      widget.habit.alarmTime = null;
      await NotificationService().cancelNotification(widget.habit.key as int);
    }

    widget.habit.save();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: theme.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '습관 수정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('습관 이름', theme),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '예: 담배 끊기',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('아이콘 선택', theme),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? theme.light : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('반복 요일', theme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuickBtn('매일', theme, _selectAll),
                        const SizedBox(width: 8),
                        _QuickBtn('평일', theme, _selectWeekdays),
                        const SizedBox(width: 8),
                        _QuickBtn('주말', theme, _selectWeekends),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final isSelected = _selectedDays[index];
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedDays[index] = !_selectedDays[index],
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? theme.primary : Colors.white,
                              border: Border.all(
                                color: theme.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _dayLabels[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : theme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle('알림 설정', theme),
                        Switch(
                          value: _useAlarm,
                          activeColor: theme.primary,
                          onChanged: (val) => setState(() => _useAlarm = val),
                        ),
                      ],
                    ),
                    if (_useAlarm) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.light,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '알림 시간',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textLight,
                                ),
                              ),
                              Text(
                                '${_alarmTime.hour.toString().padLeft(2, '0')}:${_alarmTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle('절약 금액 설정', theme),
                        Switch(
                          value: _useSaving,
                          activeColor: theme.primary,
                          onChanged: (val) => setState(() => _useSaving = val),
                        ),
                      ],
                    ),
                    if (_useSaving) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.light,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _cycleController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '일마다',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textLight,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '절약 금액',
                                      suffixText: '원',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '예: 3일마다 4,500원 → 담배 한 갑',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '수정 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _SectionTitle(String title, dynamic theme) {
  return Text(
    title,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: theme.textDark,
    ),
  );
}

Widget _QuickBtn(String label, dynamic theme, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.light,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.textLight,
        ),
      ),
    ),
  );
}
