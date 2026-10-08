import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  Comment({
    required this.id,
    required this.text,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];

    return Comment(
      id: doc.id,
      text: data['text'] ?? '',
      userName: data['userName'] ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  final String id;
  final String text;
  final String userName;
  final DateTime createdAt;
}
