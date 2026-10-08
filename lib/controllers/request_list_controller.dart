import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/request.dart';
import '../services/request_service.dart';

class RequestListController extends ChangeNotifier {
  RequestListController(this._requestService) {
    _subscription = _requestService.watchAll().listen(
      (items) {
        requests = items;
        isLoading = false;
        hasError = false;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        hasError = true;
        notifyListeners();
      },
    );
  }

  final RequestService _requestService;
  late final StreamSubscription<List<Request>> _subscription;

  List<Request> requests = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
