import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:recipe_app/pages/saved_recipe_page';
import 'package:translator/translator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/recipe.dart';
import '../../widgets/comments_section.dart';
import '../../services/saved_recipe_service.dart';
import '../about_page.dart';
import '../signup_page.dart'; // adjust path as needed

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({super.key});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();

  bool isSpeaking = false;
  String? currentlySpeakingSection;
  bool isUrdu = false;

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
    await flutterTts.setLanguage("en-US");
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
    if (isSpeaking && currentlySpeakingSection == section) {
      await flutterTts.stop();
    } else {
      currentlySpeakingSection = section;
      await flutterTts.setLanguage(isUrdu ? "ur-PK" : "en-US");
      await flutterTts.speak(text);
    }
  }

  Future<void> toggleTranslation(Recipe recipe) async {
    await flutterTts.stop();
    currentlySpeakingSection = null;
    isSpeaking = false;

    if (isUrdu) {
      setState(() {
        isUrdu = false;
        translatedTitle = null;
        translatedIngredients = null;
        translatedDescription = null;
      });
    } else {
      setState(() {
        translatedTitle = '...translating...';
        translatedIngredients = '...translating...';
        translatedDescription = '...translating...';
      });

      final title = await translator.translate(recipe.title ?? '', to: 'ur');
      final ingredients =
          await translator.translate(recipe.ingredients ?? '', to: 'ur');
      final description =
          await translator.translate(recipe.description ?? '', to: 'ur');

      setState(() {
        isUrdu = true;
        translatedTitle = title.text;
        translatedIngredients = ingredients.text;
        translatedDescription = description.text;
      });
    }
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
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: Text('Home', style: TextStyle(color: black)),
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
      color: Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Recipe) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Details'),
          backgroundColor: black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No recipe data provided.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final Recipe recipe = args;
    final imageUrl = (recipe.picture != null && recipe.picture!.isNotEmpty)
        ? recipe.picture!
        : 'https://via.placeholder.com/250.png?text=No+Image';

    final titleText = isUrdu ? translatedTitle ?? recipe.title : recipe.title;
    final ingredientsText =
        isUrdu ? translatedIngredients ?? recipe.ingredients : recipe.ingredients;
    final descriptionText =
        isUrdu ? translatedDescription ?? recipe.description : recipe.description;

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: AppBar(
        backgroundColor: black,
        title: const Text(
          '🍴 Bite Book – Your Recipedia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text('Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
            label: const Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SavedRecipesPage()));
            },
            icon: const Icon(Icons.bookmark, color: Colors.white),
            label: const Text('Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumbs(recipe.title ?? 'Detail'),

            // Title and Translate Button
            Container(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              color: babyPink.withOpacity(0.4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      titleText ?? 'Untitled Recipe',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.translate, size: 28),
                    color: black,
                    tooltip: isUrdu ? 'Show in English' : 'Translate to Urdu',
                    onPressed: () => toggleTranslation(recipe),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image (Left) + Ingredients (Right) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
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

                      // Ingredients
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isUrdu ? 'اجزاء' : 'Ingredients',
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
                                  onPressed: () => toggleSpeak(
                                      'ingredients', ingredientsText ?? ''),
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

                  // --- Description Below ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUrdu ? 'تفصیل' : 'Preparation Steps',
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
                            toggleSpeak('description', descriptionText ?? ''),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...buildNumberedList(descriptionText, isDescription: true),

                  const SizedBox(height: 20),

                  // Likes and Save Buttons
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

                  // Comments Section
                  Text(
                    isUrdu ? 'تبصرے' : 'Comments',
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

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}
