// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // class AllocationNotifier extends StateNotifier<Map<String, double>> {
// //   AllocationNotifier()
// //       : super({
// //           'Savings': 0,
// //           'Needs': 0,
// //           'Wants': 0,
// //           'Insurance': 0,
// //         });

// //   void updateAllocation(String category, double amount, bool isIncome) {
// //     final current = state[category] ?? 0;
// //     state = {
// //       ...state,
// //       category: isIncome ? current + amount : current - amount,
// //     };
// //   }
// // }

// // final allocationProvider =
// //     StateNotifierProvider<AllocationNotifier, Map<String, double>>((ref) {
// //   return AllocationNotifier();
// // });

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final allocationsProvider =
//     StateNotifierProvider<AllocationsNotifier, Map<String, double>>((ref) {
//   return AllocationsNotifier();
// });

// class AllocationsNotifier extends StateNotifier<Map<String, double>> {
//   double _grandTotal = 0.0; // Keeps track of all income ever added

//   AllocationsNotifier()
//       : super({
//           'Savings/EF': 0.0,
//           'Investment': 0.0,
//           'Wants': 0.0,
//           'Needs': 0.0,
//           'Insurance': 0.0,
//         });

//   double get grandTotal => _grandTotal;

//   void addAmount(String category, double amount) {
//     _grandTotal += amount; // Always add to grand total
//     state = {
//       ...state,
//       category: state[category]! + amount,
//     };
//   }

//   void deductAmount(String category, double amount) {
//     // Deduct only from the category, not the grand total
//     state = {
//       ...state,
//       category: state[category]! - amount,
//     };
//   }
// }
