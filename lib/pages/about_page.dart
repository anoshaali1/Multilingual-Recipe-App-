import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './signup_page.dart'; // adjust path as needed
import './saved_recipe_page';

// Assuming AboutPage needs to be imported here if it's called from another file,
// but since this is the file itself, we just ensure it's correct.

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  final Color blackColor = Colors.black;
  final Color babyPink = const Color(0xFFFFC0CB);
  final Color lightPeach = const Color(0xFFFFE5B4);

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper widget for Breadcrumbs - Kept as is, placed inside the scroll view.
  Widget _buildBreadcrumbs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/'),
            child: Text('Home', style: TextStyle(color: blackColor)),
          ),
          Icon(Icons.arrow_right, size: 16, color: blackColor),
          Text('About', style: TextStyle(fontWeight: FontWeight.bold, color: blackColor)),
        ],
      ),
    );
  }

  // Updated Footer Widget - Removed black background, made minimal
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      // Background is now lightPeach/transparent to match the body
      color: Colors.transparent, 
      child: Column(
        children: [
          Text(
            'Connect with us',
            style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                // Changed icon color to black/babyPink for better contrast on light background
                icon: FaIcon(FontAwesomeIcons.facebook, color: babyPink), 
                onPressed: () {}, // TODO: Add Facebook link
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.instagram, color: babyPink),
                onPressed: () {}, // TODO: Add Instagram link
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.youtube, color: babyPink),
                onPressed: () {}, // TODO: Add YouTube link
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

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPeach,

appBar: AppBar(
  backgroundColor: Colors.black,
  elevation: 4,
  iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon
  title: const Text(
    '🍴Bite Book – Your Recipedia',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: false,
  actions: [
    TextButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/'); // Home
      },
      icon: const Icon(Icons.home, color: Colors.white),
      label: const Text(
        'Home',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    TextButton.icon(
      onPressed: () {}, // Already on AboutPage
      icon: const Icon(Icons.info_outline, color: Colors.white),
      label: const Text(
        'About',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavedRecipesPage()), // Saved Recipes
        );
      },
      icon: const Icon(Icons.bookmark, color: Colors.white),
      label: const Text(
        'Saved',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignupPage()), // Profile
        );
      },
      icon: const Icon(Icons.person, color: Colors.white),
      label: const Text(
        'Profile',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
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
              leading: Icon(Icons.admin_panel_settings, color: blackColor),
              title: Text('Admin Panel', style: TextStyle(color: blackColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_login');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: blackColor),
              title: Text('User View', style: TextStyle(color: blackColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: blackColor),
              title: Text('About', style: TextStyle(color: blackColor)),
              onTap: () {
                Navigator.pop(context);
                // The current page is the AboutPage, so nothing happens on tap
              },
            ),
          ],
        ),
      ),

      // 3. Main body content is now combined into a single scroll view.
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView( // The main content is now fully scrollable
          child: Column(
            children: [
              // Removed _buildHeader() since we use AppBar now
              _buildBreadcrumbs(), 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: babyPink, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.info_outline, size: 70, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'About Bite Book',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Bite Book – Your Recipedia is your personal cooking companion. Whether you're a home chef or just beginning your culinary journey, Bite Book brings recipes, creativity, and community together in one place.",
                        style: TextStyle(fontSize: 16, color: blackColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '🌟 Our Mission',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "To inspire creativity in the kitchen by connecting users with diverse, easy-to-follow recipes from around the world. We aim to make cooking accessible, enjoyable, and rewarding for everyone.",
                        style: TextStyle(fontSize: 16, color: blackColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '🧑‍🍳 Features',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Explore a wide variety of recipes categorized by cuisine, difficulty, and ingredients.\n"
                        "• Save your favorite recipes and manage your personalized collection.\n"
                        "• Admin panel for managing recipe data securely.\n"
                        "• Easy navigation with a responsive and accessible design.\n"
                        "• Monthly feature updates for a fresh cooking experience.",
                        style: TextStyle(fontSize: 16, color: blackColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '📖 How to Use',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "1️⃣ Select your role from the home screen (Admin or User).\n"
                        "2️⃣ Browse recipes or manage content using the menu options.\n"
                        "3️⃣ Tap on any recipe card to view detailed ingredients and steps.\n"
                        "4️⃣ Use the search bar to quickly find dishes.\n"
                        "5️⃣ Save your favorites for easy access later.\n\n"
                        "Enjoy cooking, creating, and sharing with Bite Book!",
                        style: TextStyle(fontSize: 16, color: blackColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '💡 Design Philosophy (HCI Principles)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• **Consistency** – Uniform layout and design patterns for all pages.\n"
                        "• **Visibility** – Clear navigation and prominent interactive elements.\n"
                        "• **Feedback** – Smooth transitions and user cues for actions.\n"
                        "• **Affordance** – Buttons, icons, and colors clearly indicate functionality.\n"
                        "• **Accessibility** – High contrast and large readable text.",
                        style: TextStyle(fontSize: 16, color: blackColor, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Version 1.0.0 • Developed by Team BiteBook',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                      const SizedBox(height: 30), // Extra space before footer
                    ],
                  ),
                ),
              ),
              // Footer is now inside SingleChildScrollView, appearing upon scroll
              _buildFooter(), 
            ],
          ),
        ),
      ),
    );
  }
}