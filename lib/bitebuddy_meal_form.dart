import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiteBuddyMealPlannerPage extends StatefulWidget {
  const BiteBuddyMealPlannerPage({super.key});

  @override
  State<BiteBuddyMealPlannerPage> createState() =>
      _BiteBuddyMealPlannerPageState();
}

class _BiteBuddyMealPlannerPageState extends State<BiteBuddyMealPlannerPage> {
  String _planType = 'daily';

  final Map<String, bool> _conditions = {
    'gym': false,
    'vegan': false,
    'vegetarian': false,
    'diabetes': false,
    'bp': false,
    'heart': false,
    'lactose_intolerant': false,
    'stomach': false,
  };

  Map<String, dynamic>? _resultPlan;

  // ---------------- LOAD & MATCH JSON ----------------
  Future<void> _generatePlan() async {
    final jsonString =
        await rootBundle.loadString('assets/bitebuddy_meal_plans.json');

    final List<dynamic> plans = jsonDecode(jsonString);

    final selectedTags = _conditions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedTags.isEmpty) {
      setState(() => _resultPlan = null);
      return;
    }

    final match = plans.cast<Map<String, dynamic>>().firstWhere(
      (plan) =>
          plan['type'] == _planType &&
          selectedTags.any((tag) => plan['tags'].contains(tag)),
      orElse: () => {},
    );

    if (match.isEmpty) {
      setState(() => _resultPlan = null);
      return;
    }

    setState(() {
      _resultPlan = match['plan'] as Map<String, dynamic>?;
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🥗 BiteBuddy Meal Planner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('🍽️ Plan Type'),
            _planTypeSelector(),

            _sectionTitle('🧠 Health & Preferences'),
            _conditionsGrid(),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Meal Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: _generatePlan,
              ),
            ),

            const SizedBox(height: 30),
            if (_resultPlan != null) _resultView(),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _planTypeSelector() {
    return Row(
      children: [
        _radioTile('Daily 🍳', 'daily'),
        _radioTile('Weekly 📅', 'weekly'),
      ],
    );
  }

  Widget _radioTile(String label, String value) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: _planType,
        title: Text(label),
        onChanged: (v) {
          if (v != null) {
            setState(() => _planType = v);
          }
        },
      ),
    );
  }

  Widget _conditionsGrid() {
    final labels = {
      'gym': '💪 Gym',
      'vegan': '🌱 Vegan',
      'vegetarian': '🥦 Vegetarian',
      'diabetes': '🩺 Diabetes',
      'bp': '🧂 BP',
      'heart': '❤️ Heart',
      'lactose_intolerant': '🥛 No Dairy',
      'stomach': '🤢 Stomach',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _conditions.keys.map((key) {
        return FilterChip(
          label: Text(labels[key]!),
          selected: _conditions[key]!,
          selectedColor: Colors.orange.shade200,
          onSelected: (v) {
            setState(() => _conditions[key] = v);
          },
        );
      }).toList(),
    );
  }

  Widget _resultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('✨ Your Meal Plan'),

        if (_planType == 'daily') _dailyPlanCard(_resultPlan!),

        if (_planType == 'weekly')
          ..._resultPlan!.entries.map(
            (entry) => _weeklyDayCard(
              entry.key,
              entry.value is Map<String, dynamic>
                  ? entry.value as Map<String, dynamic>
                  : {},
            ),
          ),
      ],
    );
  }

  Widget _dailyPlanCard(Map<String, dynamic> plan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _mealRow('🍳 Breakfast', plan['breakfast']),
            _mealRow('🥗 Lunch', plan['lunch']),
            _mealRow('🍲 Dinner', plan['dinner']),
            _mealRow('🍎 Snack', plan['snack']),
          ],
        ),
      ),
    );
  }

  Widget _weeklyDayCard(String day, Map<String, dynamic> meals) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        title: Text(
          day.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          _mealRow('🍳 Breakfast', meals['breakfast']),
          _mealRow('🥗 Lunch', meals['lunch']),
          _mealRow('🍲 Dinner', meals['dinner']),
          _mealRow('🍎 Snack', meals['snack']),
        ],
      ),
    );
  }

  Widget _mealRow(String title, dynamic value) {
    final displayValue = (value ?? '-').toString(); // Safe null handling

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }
}
