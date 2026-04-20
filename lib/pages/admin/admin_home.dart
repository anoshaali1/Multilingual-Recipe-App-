import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/recipe.dart';
import '../../widgets/recipe_card.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');

  // Colors
  final Color black = Colors.black;
  final Color lightPeach = const Color(0xFFFFE5B4);
  final Color babyPink = const Color(0xFFFFC0CB);
  final Color darkPink = const Color(0xFFF08080);

  // ------------------- Drawer -------------------
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkPink, babyPink, lightPeach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, size: 36, color: black),
                const SizedBox(height: 8),
                Text(
                  '👨‍🍳 Admin Panel',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: black),
                ),
                Text(
                  'Bite Book Dashboard',
                  style: TextStyle(fontSize: 14, color: black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          _buildDrawerListTile(context, 'Dashboard', Icons.dashboard,
              () => Navigator.pop(context)),
          _buildDrawerListTile(
            context,
            'Add Recipe',
            Icons.add_circle,
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addRecipe');
            },
          ),
          _buildDrawerListTile(context, 'Manage Recipes', Icons.edit,
              () => Navigator.pop(context)),
          const Divider(),
          _buildDrawerListTile(
            context,
            'Logout',
            Icons.logout,
            () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            color: darkPink,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerListTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? black),
      title: Text(title, style: TextStyle(color: color ?? black)),
      onTap: onTap,
    );
  }

  // ------------------- Footer -------------------
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Connect with us',
            style: TextStyle(
                color: black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(FontAwesomeIcons.facebook, darkPink),
              _buildSocialButton(FontAwesomeIcons.instagram, darkPink),
              _buildSocialButton(FontAwesomeIcons.youtube, darkPink),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '© 2025 Bite Book – Admin Panel. All rights reserved.',
            style: TextStyle(color: Colors.grey[800], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: lightPeach.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: IconButton(
        icon: FaIcon(icon, color: color, size: 20),
        onPressed: () {},
      ),
    );
  }

  // ------------------- Stat Card -------------------
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      elevation: 4,
      child: Container(
        width: 150,
        height: 90,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: black.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Bar Chart -------------------
  Widget _buildBarChart(List<Recipe> allRecipes) {
    final topRecipes = allRecipes
        .where((r) => r.likes != null && r.likes! > 0)
        .toList()
        .cast<Recipe>();
    topRecipes.sort((a, b) => b.likes!.compareTo(a.likes!));
    final chartData = topRecipes.take(5).toList();

    return SizedBox(
      height: 300,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 5 Recipes by Likes ❤️',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: black),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartData.isNotEmpty
                        ? chartData.map((e) => e.likes!).reduce((a, b) => a > b ? a : b) *
                            1.1
                        : 1,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: darkPink.withOpacity(0.9),
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String title = chartData[groupIndex].title;
                          String likes = rod.toY.toInt().toString();
                          return BarTooltipItem(
                            '$title\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$likes Likes',
                                style: TextStyle(
                                  color: lightPeach,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < chartData.length) {
                              final title = chartData[index].title;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4,
                                child: Text(
                                  title.length > 8 ? '${title.substring(0, 8)}...' : title,
                                  style: const TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: chartData.isNotEmpty
                              ? (chartData.map((e) => e.likes!).reduce((a, b) => a > b ? a : b) / 4)
                                  .ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                    barGroups: List.generate(
                      chartData.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (chartData[index].likes ?? 0).toDouble(),
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            color: darkPink,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: chartData.isNotEmpty
                                  ? chartData.map((e) => e.likes!).reduce((a, b) => a > b ? a : b) *
                                      1.1
                                  : 1,
                              color: babyPink.withOpacity(0.3),
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getTotalComments(List<Recipe> allRecipes) async {
  final futures = allRecipes.map((recipe) {
    return recipes.doc(recipe.id).collection('comments').get();
  }).toList();

  final results = await Future.wait(futures);

  // Explicitly define sum as int
  return results.fold<int>(0, (int sum, snap) => sum + snap.docs.length);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPeach.withOpacity(0.4),
      appBar: AppBar(
  backgroundColor: black,
  elevation: 8,
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    '👨‍🍳 Bite Book Admin Dashboard',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: 20,
    ),
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
        onPressed: () {
          Navigator.pushNamed(context, '/addRecipe');
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: babyPink,
          foregroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
    ),
  ],
),

      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addRecipe'),
        backgroundColor: darkPink,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Recipe',
        elevation: 8,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: recipes.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pink));
          }

          final docs = snapshot.data!.docs;
          final List<Recipe> allRecipes = docs
              .map((doc) =>
                  Recipe.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          final totalRecipes = allRecipes.length;
          final totalLikes =
              allRecipes.fold<int>(0, (sum, recipe) => sum + (recipe.likes ?? 0));
          final mostLikedRecipe = allRecipes.isNotEmpty
              ? allRecipes.reduce(
                  (a, b) => (a.likes ?? 0) > (b.likes ?? 0) ? a : b)
              : null;

          return FutureBuilder<int>(
            future: _getTotalComments(allRecipes),
            builder: (context, commentSnapshot) {
              final totalComments = commentSnapshot.data ?? 0;

              int columns = MediaQuery.of(context).size.width > 1200
                  ? 5
                  : MediaQuery.of(context).size.width > 900
                      ? 4
                      : MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Header
                      Text(
                        '📊 Bitebook Dashboard Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Cards Row
                     // ------------------- Stats Cards Row -------------------
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: _buildStatCard(
        title: 'Total Recipes',
        value: totalRecipes.toString(),
        icon: Icons.fastfood_rounded,
        cardColor: babyPink.withOpacity(0.8),
        iconColor: black,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: _buildStatCard(
        title: 'Total Likes',
        value: totalLikes.toString(),
        icon: Icons.favorite,
        cardColor: darkPink.withOpacity(0.8),
        iconColor: Colors.white,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: _buildStatCard(
        title: 'Total Comments',
        value: totalComments.toString(),
        icon: Icons.comment,
        cardColor: babyPink.withOpacity(0.6),
        iconColor: black,
      ),
    ),
    if (mostLikedRecipe != null) ...[
      const SizedBox(width: 16),
      Expanded(
        flex: 2, // <-- Make this card bigger
        child: _buildStatCard(
          title: 'Most Liked',
          value: mostLikedRecipe.title,
          icon: Icons.star,
          cardColor: darkPink.withOpacity(0.7),
          iconColor: Colors.white,
        ),
      ),
    ],
  ],
),


                      const SizedBox(height: 30),

                      // Bar Chart
                      _buildBarChart(allRecipes),
                      const SizedBox(height: 30),

                      // All Recipes Header
                      Text(
                        '📚 All Recipes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Recipes Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount: allRecipes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final recipe = allRecipes[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: RecipeCard(
                              recipe: recipe,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/editRecipe',
                                arguments: recipe,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Center(child: _buildFooter()),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
