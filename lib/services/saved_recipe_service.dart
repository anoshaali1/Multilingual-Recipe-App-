import 'package:shared_preferences/shared_preferences.dart';

class SavedRecipeService {
  static const _key = 'savedRecipes';

  // Get all saved recipe IDs
  static Future<List<String>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Save a recipe ID
  static Future<void> saveRecipe(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    if (!saved.contains(recipeId)) {
      saved.add(recipeId);
      await prefs.setStringList(_key, saved);
    }
  }

  // Remove a saved recipe
  static Future<void> unsaveRecipe(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    saved.remove(recipeId);
    await prefs.setStringList(_key, saved);
  }

  // Check if a recipe is saved
  static Future<bool> isSaved(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    return saved.contains(recipeId);
  }
}
