import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _cycleController = TextEditingController(text: '1');
  String _selectedIcon = '🚬';
  final List<bool> _selectedDays = List.filled(7, false);
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  bool _useSaving = false;

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

  void _save() {
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

    int savingAmount = 0;
    int savingCycle = 1;
    if (_useSaving) {
      savingAmount =
          int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
      savingCycle = int.tryParse(_cycleController.text) ?? 1;
      if (savingCycle < 1) savingCycle = 1;
    }

    final habit = Habit(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      repeatDays: days,
      savingAmount: savingAmount,
      savingCycle: savingCycle,
    );
    Hive.box<Habit>('habits').add(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF9F27),
        title: const Text(
          '절약 습관 추가',
          style: TextStyle(
            color: Color(0xFF412402),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF412402)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('습관 이름', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '예: 담배 끊기',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('아이콘 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      color: isSelected
                          ? const Color(0xFFFAEEDA)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEF9F27)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('반복 요일', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
                      color: isSelected
                          ? const Color(0xFFEF9F27)
                          : Colors.white,
                      border: Border.all(
                        color: const Color(0xFFEF9F27),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF412402)
                              : const Color(0xFFEF9F27),
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
                const Text(
                  '절약 금액 설정',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _useSaving,
                  activeColor: const Color(0xFFEF9F27),
                  onChanged: (val) => setState(() => _useSaving = val),
                ),
              ],
            ),
            if (_useSaving) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAEEDA),
                  borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '일마다',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF633806),
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
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
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
                      style: TextStyle(fontSize: 12, color: Colors.brown[400]),
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
                  backgroundColor: const Color(0xFFEF9F27),
                  foregroundColor: const Color(0xFF412402),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
