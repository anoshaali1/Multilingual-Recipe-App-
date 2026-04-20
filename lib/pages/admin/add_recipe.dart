import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ingredientsController = TextEditingController();
  final urlImageController = TextEditingController();

  String? selectedImagePath;

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

  Future<void> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedImagePath = kIsWeb
            ? result.files.single.bytes != null
                ? String.fromCharCodes(result.files.single.bytes!)
                : null
            : result.files.single.path!;
        urlImageController.clear();
      });
    }
  }

  void saveRecipe() async {
    String imagePath = '';

    if (selectedImagePath != null) {
      imagePath = selectedImagePath!;
    } else if (urlImageController.text.trim().isNotEmpty) {
      imagePath = urlImageController.text.trim();
    }

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        ingredientsController.text.trim().isEmpty ||
        imagePath.isEmpty ||
        selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Please fill all fields, select at least one category, and provide an image'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    await FirebaseFirestore.instance.collection('recipes').add({
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'ingredients': ingredientsController.text.trim(),
      'picture': imagePath,
      'categories': selectedCategories,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final black = const Color.fromARGB(255, 15, 15, 15);
    final lightPeach = Color(0xFFFFE5B4);
    final babyPink = Color(0xFFFFC0CB);

    return Scaffold(
      backgroundColor: lightPeach.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor: black,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: kIsWeb ? 700 : double.infinity,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              // Title
              _buildTextField(titleController, 'Recipe Title', maxLines: 1),

              const SizedBox(height: 16),
              // Ingredients
              _buildTextField(ingredientsController, 'Ingredients', maxLines: 3),

              const SizedBox(height: 16),
              // Description
              _buildTextField(descriptionController, 'Description', maxLines: 4),

              const SizedBox(height: 20),
              // Categories
              const Text(
                'Select Categories:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: categories.map((cat) {
                  final isSelected = selectedCategories.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: babyPink,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : black,
                        fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),
              // Image URL
              const Text(
                "Image URL (Optional if uploading):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _buildTextField(urlImageController, 'Paste image URL here', maxLines: 1,
                  onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    selectedImagePath = null;
                  });
                }
              }),
              const SizedBox(height: 10),
              // Pick Image Button
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick Image from Device'),
                onPressed: pickImageFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: babyPink,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              // Preview Image
              if (selectedImagePath != null && !kIsWeb)
                Image.file(File(selectedImagePath!),
                    height: 140, fit: BoxFit.cover)
              else if (urlImageController.text.trim().isNotEmpty)
                Image.network(urlImageController.text.trim(),
                    height: 140, fit: BoxFit.cover),
              const SizedBox(height: 24),
              // Save Button
              ElevatedButton(
                onPressed: saveRecipe,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Recipe', style: TextStyle(fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
