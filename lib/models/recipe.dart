import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userName;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.userName,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      userName: data['userName'] ?? 'Anonymous',
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}

class Recipe {
  final String id;
  final String title;
  final String picture;
  final String ingredients;
  final String description;
  final int likes;
  List<String> categories;
  List<Comment> comments; // list of Comment objects

  Recipe({
    required this.id,
    required this.title,
    required this.picture,
    required this.ingredients,
    required this.description,
    required this.likes,
    required this.categories,
    List<Comment>? comments, // 👈 optional now
  }) : comments = comments ?? []; // 👈 default empty list

  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      picture: data['picture'] ?? '',
      ingredients: data['ingredients'] ?? '',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
      categories: data['categories'] != null
          ? List<String>.from(data['categories'])
          : [],
      comments: data['comments'] != null
          ? List<Comment>.from(
              (data['comments'] as List).map((c) => Comment.fromMap(c)))
          : [], // 👈 empty list if no comments
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'picture': picture,
      'ingredients': ingredients,
      'description': description,
      'likes': likes,
      'categories': categories,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }
}
