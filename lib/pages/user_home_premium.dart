import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'saved_recipe_page';
import 'about_page.dart';
import '../bitebuddy_meal_form.dart';
import '../services/saved_recipe_service.dart';


class UserHomePagePremium extends StatefulWidget {
  const UserHomePagePremium({super.key});

  @override
  State<UserHomePagePremium> createState() => _UserHomePagePremiumState();
}

class _UserHomePagePremiumState extends State<UserHomePagePremium> {
  final CollectionReference recipesRef =
      FirebaseFirestore.instance.collection('recipes');

  String searchQuery = '';
  bool sortAscending = true;
  String selectedCategory = 'All';

  final Color black = Colors.black;
  final Color lightPeach = const Color(0xFFFFE5B4);
  final Color babyPink = const Color(0xFFFFC0CB);

  Recipe? recipeOfTheDay;
  List<Recipe> allRecipes = [];
  List<Recipe> displayedRecipes = [];
  List<Recipe> recommendedRecipes = []; // From engine

  TutorialCoachMark? tutorialCoachMark;

  // Tutorial targets
  late List<TargetFocus> targets;
   final GlobalKey _biteBuddyKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _recipeCardKey = GlobalKey();
  final GlobalKey _likeSaveKey = GlobalKey();
  final GlobalKey _createRecipeKey = GlobalKey();
  final GlobalKey _mealPlanKey = GlobalKey();


  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Pakistani',
    'Chinese',
    'Continental',
    'Dessert',
    'Diet',
    'Fastfood',
    'Healthy Food',
  ];

  final ScrollController _recipeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  // ================= DATA =================
Future<void> _selectRandomRecipe() async {
  if (allRecipes.isEmpty) return;

  // Pick a random recipe
  recipeOfTheDay = allRecipes[Random().nextInt(allRecipes.length)];

  // No engine call needed
  setState(() {});
}


  Future<void> _fetchRecipes() async {
    final snapshot = await recipesRef.get();
    allRecipes = snapshot.docs
        .map((doc) => Recipe.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    await _selectRandomRecipe();
    _applyFilters();

    // Start tutorial after widgets exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorialOnce();
    });
  }

  void _applyFilters() {
    List<Recipe> temp = List.from(allRecipes);

    if (searchQuery.isNotEmpty) {
      temp = temp
          .where((r) => r.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (selectedCategory != 'All') {
      temp = temp
          .where((r) => (r.categories ?? []).contains(selectedCategory))
          .toList();
    }

    temp.sort((a, b) =>
        sortAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));

    setState(() => displayedRecipes = temp);
  }

  // ================= TUTORIAL =================
  Future<void> _startTutorialOnce() async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('premium_demo_seen') ?? false;

  if (!seen &&  _biteBuddyKey != null) {
    // Give widgets time to render
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));

      // Scroll to top if recipeOfDay is inside scroll
      if (_recipeScrollController.hasClients) {
        _recipeScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // Give time for scroll to complete and layout to update
        await Future.delayed(const Duration(milliseconds: 350));
      }

      // Only show tutorial if the context is available
      if ( _biteBuddyKey.currentContext != null) {
        targets = _createTargets();
        _showTutorial();
        await prefs.setBool('premium_demo_seen', true);
      } else {
        print("Recipe of the Day widget not laid out yet. Tutorial skipped.");
      }
    });
  }
}


 List<TargetFocus> _createTargets() {
  List<TargetFocus> targets = [];

  // 1️⃣ BiteBuddy first
  targets.add(
    TargetFocus(
      identify: "BiteBuddy",
      keyTarget: _biteBuddyKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Ask BiteBuddy AI for recipe tips and recommendations.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );

  // 2️⃣ Create New Recipe second
  targets.add(
    TargetFocus(
      identify: "create_recipe",
      keyTarget: _createRecipeKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tap here to create your own recipe!",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );

  // 3️⃣ Rest of the tutorial targets
  targets.addAll([
    TargetFocus(
      identify: "search",
      keyTarget: _searchKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Search recipes instantly.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "categories",
      keyTarget: _categoryKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Filter recipes by category.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "recipes",
      keyTarget: _recipeCardKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Tap a recipe to view details.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "like_save",
      keyTarget: _likeSaveKey,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Like recipes and save them.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
    TargetFocus(
      identify: "meal_plan",
      keyTarget: _mealPlanKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Check your smart meal plans here.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  ]);

  return targets;
}


  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black54,
      paddingFocus: 10,
      textSkip: "SKIP",
      onClickTarget: (target) {
        print('Target clicked: ${target.identify}');
      },
      onSkip: () {
        print("Tutorial skipped");
        return true;
      },
      onFinish: () {
        print("Tutorial finished");
      },
    );

    tutorialCoachMark!.show(context: context);
  }

  // ================= UI =================
  @override
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPeach,

      appBar: AppBar(
        backgroundColor: black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '🍴 Bite Book – Premium Kitchen',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton.icon(

            onPressed: () => Navigator.pushNamed(context, '/addRecipe'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Recipe',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _topBtn(Icons.bookmark, 'Saved', null,
              page: const SavedRecipesPage()),
          _topBtn(Icons.smart_toy, 'BiteBuddy', '/biteBuddy', key: _biteBuddyKey,),
          _topBtn(Icons.calendar_month, 'Meal Plan', '/mealPlanner', key: _mealPlanKey),
        ],
      ),

drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [babyPink, lightPeach]),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.workspace_premium, size: 42),
            SizedBox(height: 10),
            Text('Bite Book Premium',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Cook smart. Eat better.'),
          ],
        ),
      ),
      _drawerTile(Icons.bookmark, 'Saved Recipes', null,
          page: const SavedRecipesPage()),
      _drawerTile(Icons.smart_toy, 'BiteBuddy AI Chef', '/biteBuddy'),
      _drawerTile(Icons.calendar_today, 'Smart Meal Studio', '/mealPlanner'),
      const Divider(),
      _drawerTile(Icons.info_outline, 'About', null, page: AboutPage()),

      // ✅ Logout button
      _drawerTile(Icons.logout, 'Logout', null, onTap: () {
        Navigator.pushReplacementNamed(context, '/'); // Go back to SelectionPage
      }),
    ],
  ),
),


      body: SingleChildScrollView(
        child: Column(
          children: [
            _welcomeHeader(),

            /// 🔹 FEATURE BOXES
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  if (recipeOfTheDay != null)
                    _squareBox(
                      title: 'Recipe of the Day',
                      icon: Icons.star,
                      recipe: recipeOfTheDay,
                      onTap: () => Navigator.pushNamed(
                          context, '/recipeDetails',
                          arguments: recipeOfTheDay),
                    ),
                  _squareBox(
                    title: 'Bored?\nCreate New Recipe',
                    key: _createRecipeKey,
                    icon: Icons.add_circle_outline,
                    onTap: () =>
                        Navigator.pushNamed(context, '/addRecipe'),
                  ),
                  _squareBox(
  title: 'Recipes Created',
  icon: Icons.collections_bookmark,
  recipe: allRecipes.isNotEmpty
      ? allRecipes[Random().nextInt(allRecipes.length)]
      : null,
  onTap: _showRandomRecipesDialog,
),

                ],
              ),
            ),

            /// 🔍 SEARCH + SORT (RESTORED)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    key: _searchKey,
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search recipes...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) {
                        searchQuery = val;
                        _applyFilters();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(sortAscending
                        ? Icons.sort_by_alpha
                        : Icons.sort),
                    onPressed: () {
                      sortAscending = !sortAscending;
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            /// 🏷️ CATEGORY CHIPS (RESTORED)
            _buildCategoryChips(),

            /// 🍽️ GRID
            GridView.builder(
              key: _recipeCardKey, 
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: displayedRecipes.length,
           itemBuilder: (_, i) {
  return Container(
    key: i == 0 ? _likeSaveKey : null, // ✅ stable tutorial target
    child: _buildAnimatedRecipeCard(displayedRecipes[i]),
  );
},

            ),

            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  Widget _topBtn(IconData icon, String text, String? route,
      {Widget? page, Key? key}) {
    return TextButton.icon(
      key: key, 
      onPressed: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => page));
        }
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _welcomeHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text('Welcome Anosha Ali!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Wanna cook a quick bite? 🍳',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        key: _searchKey,
        decoration: const InputDecoration(
          hintText: 'Search recipes...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (val) {
          searchQuery = val;
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return ChoiceChip(
            key: cat == 'All' ? _categoryKey : null,
            label: Text(cat),
            selected: isSelected,
            selectedColor: babyPink,
            labelStyle: TextStyle(
                color: isSelected ? Colors.white : black,
                fontWeight: FontWeight.bold),
            onSelected: (_) {
              selectedCategory = cat;
              _applyFilters();
            },
          );
        },
      ),
    );
  }

  Widget _squareBox({
  required String title,
  Key? key,
  required IconData icon,
  VoidCallback? onTap,
  Recipe? recipe,
}) {
  return InkWell(
    key: key,
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(icon, size: 38, color: babyPink),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 6),

          // Conditional bottom text
          if (title == 'Recipes Created')
            const Text(
              '5 recipes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            )
          else if (recipe != null)
            Text(
              recipe.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    ),
  );
}
void _showRandomRecipesDialog() {
  if (allRecipes.isEmpty) return;

  final preview = List<Recipe>.from(allRecipes)..shuffle();
  final randomRecipes = preview.take(4).toList();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Recipes Created',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: babyPink.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.collections_bookmark,
                          color: babyPink, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recipes Created',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  '${allRecipes.length} recipes in your kitchen',
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 18),

                // Recipe preview list
                ...randomRecipes.map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: babyPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/addRecipe');
                      },
                      child: const Text(
                        'Create More',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },

    // 🔥 Smooth premium animation
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: curved,
          child: child,
        ),
      );
    },
  );
} 

  Widget _buildRecipeGrid() {
    return GridView.builder(
      key: _recipeCardKey,
      controller: _recipeScrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75),
      itemCount: displayedRecipes.length,
      itemBuilder: (_, i) {
        return Container(
          key: i == 0 ? _likeSaveKey : null,
          child: _buildAnimatedRecipeCard(displayedRecipes[i]),
        );
      },
    );
  }

  Widget _recommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('💡 Recommended for you', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedRecipes.length,
            itemBuilder: (_, i) {
              final recipe = recommendedRecipes[i];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _squareBox(
                  title: recipe.title,
                  icon: Icons.restaurant_menu,
                  recipe: recipe,
                  onTap: () => Navigator.pushNamed(context, '/premiumrecipes', arguments: recipe),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

// ---------------- DRAWER ----------------
Widget _buildDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [babyPink, lightPeach]),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.workspace_premium, size: 42),
              SizedBox(height: 10),
              Text('Bite Book Premium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Cook smart. Eat better.'),
            ],
          ),
        ),
        _drawerTile(Icons.bookmark, 'Saved Recipes', '/savedRecipes', page: const SavedRecipesPage()),
        _drawerTile(Icons.smart_toy, 'BiteBuddy AI Chef', null, page: const BiteBuddyMealPlannerPage()),
        _drawerTile(Icons.calendar_today, 'Smart Meal Studio', '/mealPlanner'),
        const Divider(),
        _drawerTile(Icons.info_outline, 'About', null, page: AboutPage()),
        _drawerTile(Icons.logout, 'Logout', null, onTap: _handleLogout),
      ],
    ),
  );
}

Widget _drawerTile(IconData icon, String title, String? route, {Widget? page, VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      if (onTap != null) {
        onTap();
      } else if (route != null) {
        Navigator.pushNamed(context, route);
      } else if (page != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      }
    },
  );
}

// ---------------- LOGOUT ----------------
void _handleLogout() {
  Navigator.pushReplacementNamed(context, '/'); // goes to SelectionPage
}

 // 🔴 Animated card + footer EXACTLY SAME AS YOURS
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text('Connect with us',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook, color: babyPink),
                  onPressed: () {}),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram, color: babyPink),
                  onPressed: () {}),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.youtube, color: babyPink),
                  onPressed: () {}),
            ],
          ),
          const Text('© 2025 Bite Book',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ⚠ animated recipe card unchanged

 Widget _buildAnimatedRecipeCard(Recipe recipe) {
  bool isHovered = false;

  return StatefulBuilder(

    builder: (context, setHoverState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setHoverState(() => isHovered = true),
        onExit: (_) => setHoverState(() => isHovered = false),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 1.0, end: isHovered ? 1.05 : 1.0),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Card(
                elevation: isHovered ? 8 : 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/premiumrecipes',
                    arguments: recipe,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Recipe Image
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            recipe.picture.isNotEmpty
                                ? recipe.picture
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Info Section
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column with Title, Likes, Try it
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Title with star icon
                                    Row(
                                      children: [
                                        const Icon(Icons.food_bank, size: 17, color: Colors.orange),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            recipe.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),

                                    // Likes and bookmark
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite, size: 18, color: Colors.red),
                                        const SizedBox(width: 2),
                                        Text('${recipe.likes}',
                                            style: const TextStyle(fontSize: 10)),
                                        const SizedBox(width: 4),
                                        FutureBuilder<bool>(
                                          future: SavedRecipeService.isSaved(recipe.id),
                                          builder: (context, snapshot) {
                                            bool saved = snapshot.data ?? false;
                                            return IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: Icon(
                                                saved
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                size: 18,
                                                color: Colors.black87,
                                              ),
                                              onPressed: () async {
                                                if (saved) {
                                                  await SavedRecipeService.unsaveRecipe(recipe.id);
                                                } else {
                                                  await SavedRecipeService.saveRecipe(recipe.id);
                                                }
                                                setState(() {});
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(saved
                                                        ? 'Recipe Removed!'
                                                        : 'Recipe Saved!'),
                                                    duration:
                                                        const Duration(milliseconds: 800),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),

                                    // Try it text with fire icon
                                    // Row(
                                    //   children: const [
                                    //     Icon(Icons.local_fire_department,
                                    //         size: 12, color: Colors.redAccent),
                                    //     SizedBox(width: 2),
                                    //     Flexible(
                                    //       child: Text(
                                    //         'Try it to impress your friends!',
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: TextStyle(
                                    //           fontSize: 10,
                                    //           color: Colors.black54,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),

                              // Arrow icon
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                                onPressed: () => Navigator.pushNamed(
                                    context, '/premiumrecipes',
                                    arguments: recipe),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

}
