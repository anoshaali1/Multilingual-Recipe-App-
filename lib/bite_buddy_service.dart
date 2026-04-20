import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:string_similarity/string_similarity.dart';

class BiteBuddyEngine {
  late List<dynamic> _knowledgeBase;

  // Load JSON knowledge base
  Future<void> loadKnowledge() async {
    final data = await rootBundle.loadString('assets/bitebuddy_knowledge.json');
    _knowledgeBase = jsonDecode(data);
  }

  // Fuzzy response logic
  String getFuzzyResponse(String userInput) {
    userInput = userInput.toLowerCase();

    String? bestAnswer;
    double bestScore = 0.0;

    for (var item in _knowledgeBase) {
      List<dynamic> questions = item['questions'];
      for (var q in questions) {
        double score = StringSimilarity.compareTwoStrings(
          userInput,
          q.toString().toLowerCase(),
        );
        if (score > bestScore) {
          bestScore = score;
          bestAnswer = item['answer'];
        }
      }
    }

    if (bestScore >= 0.3 && bestAnswer != null) {
      return bestAnswer;
    }

    // Fallback if no match
    var fallback = _knowledgeBase.firstWhere(
        (element) => element['intent'] == 'fallback',
        orElse: () => null);
    return fallback != null
        ? fallback['answer']
        : "I'm not sure about that. 😅 Can you try asking in a different way?";
  }
}
