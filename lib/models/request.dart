import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  Request({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Request.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];

    return Request(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      latitude: (data['latitude'])?.toDouble() ?? 0,
      longitude: (data['longitude'])?.toDouble() ?? 0,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String description;
  final String photoUrl;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
}
