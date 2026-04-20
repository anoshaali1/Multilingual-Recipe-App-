import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/recipe.dart';
import '../saved_recipe_page';
import '../about_page.dart';
import '../signup_page.dart';
import '../../services/saved_recipe_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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

  @override
  void initState() {
    super.initState();
    _selectRandomRecipe();
    _fetchRecipes();
  }

  Future<void> _selectRandomRecipe() async {
    final snapshot = await recipesRef.get();
    final all = snapshot.docs;
    if (all.isNotEmpty) {
      final randomDoc = all[Random().nextInt(all.length)];
      setState(() {
        recipeOfTheDay = Recipe.fromMap(
          randomDoc.id,
          randomDoc.data() as Map<String, dynamic>,
        );
      });
    }
  }

  Future<void> _fetchRecipes() async {
    final snapshot = await recipesRef.get();
    setState(() {
      allRecipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Recipe> temp = List.from(allRecipes);
    if (searchQuery.isNotEmpty) {
      temp = temp.where((r) => r.title.toLowerCase().contains(searchQuery)).toList();
    }
    if (selectedCategory != 'All') {
      temp = temp.where((r) => (r.categories ?? []).contains(selectedCategory)).toList();
    }
    temp.sort((a, b) =>
        sortAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    displayedRecipes = temp;
  }

  Widget _buildBreadcrumbs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('Home'),
          Icon(Icons.arrow_right, size: 16),
          Text('Browse Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
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
            label: Text(cat),
            selected: isSelected,
            selectedColor: babyPink,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : black,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) {
              setState(() {
                selectedCategory = cat;
                _applyFilters();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text('Connect with us', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Text('© 2025 Bite Book', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // 2. Added a consistent Drawer
drawer: Drawer(
  backgroundColor: Colors.white,
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [babyPink, lightPeach],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.book, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(
              'Bite Book',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              'Your Recipedia',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
      ListTile(
        leading: Icon(Icons.admin_panel_settings, color: Colors.black),
        title: Text('Admin Panel', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/admin_login');
        },
      ),
      ListTile(
        leading: Icon(Icons.person, color: Colors.black),
        title: Text('User View', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/user');
        },
      ),
      ListTile(
        leading: Icon(Icons.info_outline, color: Colors.black),
        title: Text('About', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context);
          // Current page is AboutPage, so nothing happens
        },
      ),
      ListTile(
        leading: Icon(Icons.select_all, color: Colors.black),
        title: Text('Selection Page', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/');
        },
      ),
    ],
  ),
),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBreadcrumbs(),

            // Recipe of the Day Header
            // ================= RECIPE OF THE DAY =================
if (recipeOfTheDay != null)
  Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ Header
        Row(
          children: const [
            Icon(Icons.star, color: Colors.amber, size: 22),
            SizedBox(width: 6),
            Text(
              'Recipe of the Day',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/recipeDetails',
                arguments: recipeOfTheDay,
              );
            },
            child: Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    recipeOfTheDay!.picture.isNotEmpty
                        ? recipeOfTheDay!.picture
                        : 'https://via.placeholder.com/150',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                // TEXT CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE
                        Text(
                          recipeOfTheDay!.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // LIKES
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipeOfTheDay!.likes} likes',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🔥 FIRE + TEXT (INSIDE CARD)
                        Row(
                          children: const [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Try it to impress your friends!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
// ================= END =================


            // Centered Search Bar + Sort
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val.toLowerCase();
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(sortAscending ? Icons.sort_by_alpha : Icons.sort, color: black),
                    onPressed: () {
                      setState(() {
                        sortAscending = !sortAscending;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),

            _buildCategoryChips(),

            // Recipe Grid (Static)
           GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: const EdgeInsets.all(8),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.75,// 🔥 IMPORTANT
  ),
  itemCount: displayedRecipes.length,
  itemBuilder: (context, index) {
    return _buildAnimatedRecipeCard(displayedRecipes[index]);
  },
),


            _buildFooter(),
          ],
        ),
      ),
    );
  }

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
                    '/recipeDetails',
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
                                    context, '/recipeDetails',
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