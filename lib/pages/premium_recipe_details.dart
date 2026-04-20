import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/recipe.dart';
import '../../widgets/comments_section.dart';
import '../../services/saved_recipe_service.dart';
import '../pages/signup_page.dart';
import '../bitebuddy.dart'; // BiteBuddy Page
import '../bitebuddy_meal_form.dart'; // Recommendation Engine Page
import '../pages/saved_recipe_page';

class RecipeDetailsPagePremium extends StatefulWidget {
  const RecipeDetailsPagePremium({super.key});

  @override
  State<RecipeDetailsPagePremium> createState() =>
      _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPagePremium> {
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();

  bool isSpeaking = false;
  String? currentlySpeakingSection;
  String selectedLanguage = 'en';

  final Map<String, String> languageNames = {
    'en': 'English',
    'ur': 'Urdu',
    'hi': 'Hindi',
    'ar': 'Arabic',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
  };

  final Map<String, String> languageLocales = {
    'en': 'en-US',
    'ur': 'ur-PK',
    'hi': 'hi-IN',
    'ar': 'ar-SA',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
  };

  final Color black = Colors.black;
  final Color lightPeach = const Color(0xFFFFE5B4);
  final Color babyPink = const Color(0xFFFFC0CB);

  String? translatedTitle;
  String? translatedIngredients;
  String? translatedDescription;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.awaitSpeakCompletion(true);

    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        currentlySpeakingSection = null;
      });
    });
    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false;
        currentlySpeakingSection = null;
      });
    });
  }

  Future<void> toggleSpeak(String section, String text) async {
    if (text.isEmpty) return;

    if (isSpeaking && currentlySpeakingSection == section) {
      await flutterTts.stop();
      return;
    }

    currentlySpeakingSection = section;

    String locale = languageLocales[selectedLanguage] ?? 'en-US';
    await flutterTts.setLanguage(locale);

    final voices = await flutterTts.getVoices;
    String? selectedVoice;
    for (var voice in voices) {
      final name = voice['name']?.toString().toLowerCase() ?? '';
      final lang = voice['locale']?.toString().toLowerCase() ?? '';
      if (lang == locale.toLowerCase() &&
          (name.contains('female') || name.contains('woman') || name.contains('zira'))) {
        selectedVoice = voice['name'];
        break;
      }
    }

    if (selectedVoice != null) {
      await flutterTts.setVoice({'name': selectedVoice, 'locale': locale});
    }

    await flutterTts.speak(text);
  }

  // Translate text only, do NOT auto-speak
  Future<void> toggleTranslation(Recipe recipe, String lang) async {
    setState(() {
      translatedTitle = '⌛ Translating...';
      translatedIngredients = '⌛ Translating...';
      translatedDescription = '⌛ Translating...';
      selectedLanguage = lang;
    });

    final title = await translator.translate(recipe.title, to: lang);
    final ingredients = await translator.translate(recipe.ingredients, to: lang);
    final description = await translator.translate(recipe.description, to: lang);

    setState(() {
      translatedTitle = title.text;
      translatedIngredients = ingredients.text;
      translatedDescription = description.text;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void likeRecipe(String recipeId) {
    FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .update({'likes': FieldValue.increment(1)});
  }

  List<Widget> buildNumberedList(String? text, {bool isDescription = false}) {
    if (text == null || text.isEmpty) return [const Text('No data available.')];
    final items = text.split(RegExp(r'\n|\r|\s{2,}'));
    int count = 1;
    return items
        .where((item) => item.trim().isNotEmpty)
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                isDescription
                    ? 'Step ${count++}: ${item.trim()}'
                    : '${count++}. ${item.trim()}',
                style: const TextStyle(fontSize: 16),
              ),
            ))
        .toList();
  }

  Widget _buildBreadcrumbs(String recipeTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
          Icon(Icons.arrow_right, size: 16, color: black),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Browse Recipes', style: TextStyle(color: black)),
          ),
          Icon(Icons.arrow_right, size: 16, color: black),
          Expanded(
            child: Text(
              recipeTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text('Connect with us',
              style: TextStyle(color: black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.facebook, color: babyPink),
                onPressed: () {},
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.instagram, color: babyPink),
                onPressed: () {},
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.youtube, color: babyPink),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '© 2025 Bite Book – All rights reserved.',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _topBtn(IconData icon, String label, String? route, {Widget? page}) {
    return TextButton.icon(
      onPressed: () {
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        } else if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Recipe) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Details'),
          backgroundColor: black,
        ),
        body: const Center(
          child: Text('No recipe data provided.'),
        ),
      );
    }

    final Recipe recipe = args;
    final imageUrl = (recipe.picture != null && recipe.picture!.isNotEmpty)
        ? recipe.picture!
        : 'https://via.placeholder.com/250.png?text=No+Image';

    final titleText = translatedTitle ?? recipe.title;
    final ingredientsText = translatedIngredients ?? recipe.ingredients;
    final descriptionText = translatedDescription ?? recipe.description;

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🍴 Bite Book – Premium Kitchen',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          _topBtn(Icons.add, 'Create Recipe', null,
              page: const SizedBox()), // replace with add recipe page
          _topBtn(Icons.bookmark, 'Saved', null, page: const SavedRecipesPage()),
          _topBtn(Icons.smart_toy, 'BiteBuddy', '/biteBuddy'),
          _topBtn(Icons.calendar_month, 'Meal Plan', '/mealPlanner'),
          PopupMenuButton<String>(
            onSelected: (lang) => toggleTranslation(recipe, lang),
            icon: const Icon(Icons.language),
            itemBuilder: (context) => languageNames.entries
                .map((entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumbs(recipe.title ?? 'Detail'),
            Container(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              color: babyPink.withOpacity(0.4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titleText ?? 'Untitled Recipe',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            width: 300,
                            color: babyPink,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ingredients',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isSpeaking &&
                                            currentlySpeakingSection ==
                                                'ingredients'
                                        ? Icons.stop
                                        : Icons.volume_up,
                                  ),
                                  onPressed: () =>
                                      toggleSpeak('ingredients', ingredientsText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...buildNumberedList(ingredientsText),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preparation Steps',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      IconButton(
                        icon: Icon(
                          isSpeaking && currentlySpeakingSection == 'description'
                              ? Icons.stop
                              : Icons.volume_up,
                        ),
                        onPressed: () =>
                            toggleSpeak('description', descriptionText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...buildNumberedList(descriptionText, isDescription: true),
                  const SizedBox(height: 20),
                  FutureBuilder<bool>(
                    future: SavedRecipeService.isSaved(recipe.id),
                    builder: (context, snapshot) {
                      final isSaved = snapshot.data ?? false;
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.red),
                            onPressed: () {
                              likeRecipe(recipe.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Thanks for liking!')),
                              );
                            },
                          ),
                          Text('${recipe.likes} Likes',
                              style: TextStyle(color: black)),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              if (isSaved) {
                                await SavedRecipeService.unsaveRecipe(recipe.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Removed from saved recipes')),
                                );
                              } else {
                                await SavedRecipeService.saveRecipe(recipe.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Recipe saved')),
                                );
                              }
                              (context as Element).markNeedsBuild();
                            },
                          ),
                          Text(isSaved ? 'Saved' : 'Save',
                              style: TextStyle(color: black)),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 40),
                  Text(
                    'Anonymous – Comments',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: black),
                  ),
                  const SizedBox(height: 10),
                  CommentSection(recipeId: recipe.id),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}
