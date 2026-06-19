import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: currentTheme.background,
      appBar: AppBar(
        backgroundColor: currentTheme.background,
        elevation: 0,
        title: Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: currentTheme.textDark,
          ),
        ),
        iconTheme: IconThemeData(color: currentTheme.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '컬러 테마',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: currentTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...AppThemes.themes.asMap().entries.map((entry) {
              final index = entry.key;
              final theme = entry.value;
              final isSelected = themeProvider.themeIndex == index;

              return GestureDetector(
                onTap: () => themeProvider.setTheme(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.light : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? theme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.textDark
                              : const Color(0xFF2C2C2A),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              '저축 금융앱',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: currentTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '"지금 저축하기" 버튼을 누르면 선택한 앱이 열려요',
              style: TextStyle(fontSize: 12, color: currentTheme.textLight),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BankApps.apps.asMap().entries.map((entry) {
                final index = entry.key;
                final bank = entry.value;
                final isSelected = themeProvider.bankIndex == index;

                return GestureDetector(
                  onTap: () => themeProvider.setBank(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? currentTheme.light : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? currentTheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${bank.emoji} ${bank.name}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? currentTheme.textDark
                            : const Color(0xFF2C2C2A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
