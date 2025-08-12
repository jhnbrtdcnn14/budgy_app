import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/provider.dart/theme_notifier.dart';
import 'package:budgy_app/screens/allocation_screen.dart';
import 'package:budgy_app/screens/setting_screen.dart';
import 'package:budgy_app/screens/wallet_screens.dart';
import 'package:budgy_app/screens/statistics_screen.dart';
import 'package:budgy_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/calculation_screen.dart';

void main() {
  runApp(const ProviderScope(child: BudgetApp()));
}

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budgy',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        scaffoldBackgroundColor: AppColors.primaryDark,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        scaffoldBackgroundColor: AppColors.primaryDark,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/calculation': (context) => const CalculationScreen(),
        '/allocations': (context) => const AllocationScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/statistic': (context) => const StatisticsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
