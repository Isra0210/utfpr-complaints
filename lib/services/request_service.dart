import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/comment.dart';
import '../models/request.dart';

class RequestService {
  RequestService({FirebaseFirestore? db, FirebaseStorage? storage})
    : _db = db ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('requests');

  Stream<List<Request>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Request.fromDoc).toList());
  }

  Stream<Request?> watchById(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Request.fromDoc(doc) : null);
  }

  Future<String> uploadPhoto({
    required File photo,
    required String userId,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
    final ref = _storage.ref().child('requests').child(fileName);
    await ref.putFile(photo);
    return ref.getDownloadURL();
  }

  Future<void> create({
    required String title,
    required String description,
    required String photoUrl,
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
  }) {
    return _collection.add({
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String id,
    required String title,
    required String description,
  }) {
    return _collection.doc(id).update({
      'title': title,
      'description': description,
    });
  }

  Future<void> delete(Request request) async {
    await _collection.doc(request.id).delete();

    if (request.photoUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(request.photoUrl).delete();
      } on FirebaseException {
        return;
      }
    }
  }

  Stream<List<Comment>> watchComments(String requestId) {
    return _collection
        .doc(requestId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Comment.fromDoc).toList());
  }

  Future<void> addComment({
    required String requestId,
    required String text,
    required String userName,
  }) {
    return _collection.doc(requestId).collection('comments').add({
      'text': text,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
