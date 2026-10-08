import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../models/request.dart';
import '../services/auth_service.dart';
import '../services/request_service.dart';

class RequestDetailController extends ChangeNotifier {
  RequestDetailController({
    required RequestService requestService,
    required AuthService authService,
    required this.requestId,
  }) : _requestService = requestService,
       _authService = authService {
    _requestSubscription = _requestService.watchById(requestId).listen((value) {
      request = value;
      isLoadingRequest = false;
      notifyListeners();
    });
    _commentsSubscription = _requestService.watchComments(requestId).listen((
      items,
    ) {
      comments = items;
      notifyListeners();
    });
  }

  final RequestService _requestService;
  final AuthService _authService;
  final String requestId;

  late final StreamSubscription<Request?> _requestSubscription;
  late final StreamSubscription<List<Comment>> _commentsSubscription;

  Request? request;
  bool isLoadingRequest = true;
  List<Comment> comments = [];

  bool get isOwner =>
      request != null && request!.userId == _authService.currentUser?.uid;

  Future<void> update({required String title, required String description}) {
    return _requestService.update(
      id: requestId,
      title: title,
      description: description,
    );
  }

  Future<void> delete() {
    final current = request;

    if (current == null) return Future.value();

    return _requestService.delete(current);
  }

  Future<void> addComment(String text) {
    return _requestService.addComment(
      requestId: requestId,
      text: text,
      userName: _authService.currentUserName,
    );
  }

  @override
  void dispose() {
    _requestSubscription.cancel();
    _commentsSubscription.cancel();

    super.dispose();
  }
}
