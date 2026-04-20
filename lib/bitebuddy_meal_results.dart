import 'package:flutter/material.dart';
import 'bitebuddy_nourish_engine.dart';

class BiteBuddyMealResult extends StatefulWidget {
  final String planType;
  final List<String> preferences;
  final List<String> restrictions;

  const BiteBuddyMealResult({
    super.key,
    required this.planType,
    required this.preferences,
    required this.restrictions,
  });

  @override
  State<BiteBuddyMealResult> createState() => _BiteBuddyMealResultState();
}

class _BiteBuddyMealResultState extends State<BiteBuddyMealResult> {
  final engine = BiteBuddyNourishEngine();
  Map<String, dynamic>? plan;

  @override
  void initState() {
    super.initState();
    engine.loadPlans().then((_) {
      setState(() {
        plan = engine.recommendPlan(
          planType: widget.planType,
          preferences: widget.preferences,
          restrictions: widget.restrictions,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('No meal plan found 😔')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍴 Your BiteBuddy Plan'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: plan!.entries.map((entry) {
          return Card(
            child: ListTile(
              title: Text(entry.key.toUpperCase()),
              subtitle: Text(entry.value.toString()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
