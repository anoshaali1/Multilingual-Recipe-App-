import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/recipe.dart';

class EditRecipePage extends StatefulWidget {
  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late Recipe recipe;

  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final pictureCtrl = TextEditingController();
  final ingredientsCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  // Categories
  final List<String> categories = [
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
  final List<String> selectedCategories = [];

  final Color blackColor = Colors.black;
  final Color lightPeach = Color(0xFFFFE5B4);
  final Color babyPink = Color(0xFFFFC0CB);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    titleCtrl.text = recipe.title;
    pictureCtrl.text = recipe.picture;
    ingredientsCtrl.text = recipe.ingredients;
    descriptionCtrl.text = recipe.description;
    if (recipe.categories != null) {
      selectedCategories.addAll(recipe.categories!);
    }
  }

  void updateRecipe() {
    if (_formKey.currentState!.validate()) {
      if (selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select at least one category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String imagePath = pictureCtrl.text.trim().isNotEmpty
          ? pictureCtrl.text.trim()
          : 'https://via.placeholder.com/150';

      FirebaseFirestore.instance.collection('recipes').doc(recipe.id).update({
        'title': titleCtrl.text.trim(),
        'picture': imagePath,
        'ingredients': ingredientsCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'categories': selectedCategories,
      }).then((_) => Navigator.pop(context));
    }
  }

  Future<void> deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipe.id)
          .delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: lightPeach,
      appBar: AppBar(
        title: const Text(
          'Edit Recipe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blackColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleCtrl,
                            decoration: _inputDecoration('Title'),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: ingredientsCtrl,
                            decoration: _inputDecoration('Ingredients'),
                            maxLines: 3,
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Ingredients are required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionCtrl,
                            decoration: _inputDecoration('Description'),
                            maxLines: 5,
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Description is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Categories:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: categories.map((cat) {
                              final isSelected = selectedCategories.contains(cat);
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                selectedColor: babyPink,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : blackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedCategories.remove(cat);
                                    } else {
                                      selectedCategories.add(cat);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: pictureCtrl,
                            decoration: _inputDecoration('Image URL (optional)'),
                          ),
                          const SizedBox(height: 12),
                          if (pictureCtrl.text.trim().isNotEmpty)
                            Image.network(pictureCtrl.text.trim(),
                                height: 120, fit: BoxFit.cover),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: _inputDecoration('Title'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ingredientsCtrl,
                      decoration: _inputDecoration('Ingredients'),
                      maxLines: 3,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Ingredients are required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionCtrl,
                      decoration: _inputDecoration('Description'),
                      maxLines: 5,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text('Select Categories:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: categories.map((cat) {
                        final isSelected = selectedCategories.contains(cat);
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: babyPink,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : blackColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            setState(() {
                              if (isSelected) {
                                selectedCategories.remove(cat);
                              } else {
                                selectedCategories.add(cat);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: pictureCtrl,
                      decoration: _inputDecoration('Image URL (optional)'),
                    ),
                    const SizedBox(height: 12),
                    if (pictureCtrl.text.trim().isNotEmpty)
                      Image.network(pictureCtrl.text.trim(), height: 120, fit: BoxFit.cover),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: updateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.save, color: babyPink),
                label: Text('Update Recipe', style: TextStyle(fontSize: 16, color: babyPink)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: deleteRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text('Delete Recipe',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: blackColor),
      filled: true,
      fillColor: babyPink.withOpacity(0.2),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: babyPink, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: blackColor),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
