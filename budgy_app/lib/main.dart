import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/screens/allocation_screen.dart';
import 'package:budgy_app/screens/wallet_screens.dart';
import 'package:budgy_app/screens/statistics_screen.dart';
import 'package:budgy_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/calculation_screen.dart';

void main() {
  runApp(ProviderScope(child: const BudgetApp()));
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budgy',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        scaffoldBackgroundColor: AppColors.white,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/calculation': (context) => const CalculationScreen(),
        '/allocations': (context) => const AllocationScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/statistic': (context) => const StatisticsScreen(),
      },
    );
  }
}
