import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/provider.dart/theme_notifier.dart';
import 'package:budgy_app/screens/calculation_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../components/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      body: Stack(children: [
        FuturisticBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_rounded, color: AppColors.primaryLight),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/wallet');
                          },
                        ),
                      ],
                    ),
                    AppText(
                      text: 'Settings',
                      size: "xxlarge",
                      color: AppColors.primaryLight,
                      isBold: true,
                    ),
                     SizedBox.square(
                        dimension: 30,
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: AppText(text: 'Dark Mode', size: 'medium', color: AppColors.primaryLight),
                        value: isDarkMode,
                        onChanged: (_) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
