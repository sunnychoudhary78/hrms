import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/shared/widgets/app_bar.dart';
import '../../../../core/theme/app_theme_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = ref.watch(appThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final colors = [
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.pink,
    ];

    return Scaffold(
      appBar: AppAppBar(title: "Settings"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🌙 Light / Dark Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref
                        .read(themeModeProvider.notifier)
                        .changeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 🎨 Color Palette Title
            const Text(
              "Choose Primary Color",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// 🎨 Color Options
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) {
                final isSelected = selectedColor.value == color.value;

                return GestureDetector(
                  onTap: () {
                    ref.read(appThemeProvider.notifier).changeColor(color);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
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
