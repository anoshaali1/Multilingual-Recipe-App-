import 'dart:convert';
import 'package:flutter/services.dart';

class BiteBuddyNourishEngine {
  late List<dynamic> _mealPlans;

  Future<void> loadPlans() async {
    final data =
        await rootBundle.loadString('assets/bitebuddy_meal_plans.json');
    _mealPlans = jsonDecode(data);
  }

  Map<String, dynamic>? recommendPlan({
    required String planType, // daily | weekly
    required List<String> preferences,
    required List<String> restrictions,
  }) {
    for (var plan in _mealPlans) {
      if (plan['type'] != planType) continue;

      final tags = List<String>.from(plan['tags']);
      final planRestrictions = List<String>.from(plan['restrictions']);

      if (!preferences.any((p) => tags.contains(p))) continue;
      if (restrictions.any((r) => planRestrictions.contains(r))) continue;

      return plan['plan'];
    }

    return null;
  }
}
