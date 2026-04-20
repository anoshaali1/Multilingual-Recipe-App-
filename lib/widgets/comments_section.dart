import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentSection extends StatefulWidget {
  final String recipeId;
  CommentSection({required this.recipeId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();

  Future<void> addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('comments')
        .add({
      'userName': 'Anonymous',
      'comment': text,
      'timestamp': Timestamp.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('recipes')
              .doc(widget.recipeId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            final comments = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: comments.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = comments[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(data['userName'] ?? 'User'),
                  subtitle: Text(data['comment']),
                );
              },
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Add a comment...'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: addComment,
            )
          ],
        )
      ],
    );
  }
}
