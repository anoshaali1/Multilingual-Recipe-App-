import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  RecipeCard({required this.recipe, required this.onTap});

  final Color black = Colors.black;
  final Color lightPeach = Color(0xFFFFE5B4);
  final Color babyPink = Color(0xFFFFC0CB);

  @override
 @override
Widget build(BuildContext context) {
  final imageUrl = recipe.picture.isNotEmpty
      ? recipe.picture
      : 'https://via.placeholder.com/150x100.png?text=No+Image';

  return GestureDetector(
    onTap: onTap,
    child: Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
  height: 280, // Increased card height
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ✅ Bigger Image
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Image.network(
          imageUrl,
          height: 160, // Increased image height
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 160,
            color: babyPink,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),

            // Title
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                recipe.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Arrow + Like Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Like', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: babyPink),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('recipes')
                          .doc(recipe.id)
                          .update({'likes': FieldValue.increment(1)});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: babyPink),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}