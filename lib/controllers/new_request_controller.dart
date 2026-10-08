import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/request_service.dart';

class NewRequestController extends ChangeNotifier {
  NewRequestController({
    required RequestService requestService,
    required AuthService authService,
    required LocationService locationService,
    ImagePicker? imagePicker,
  }) : _requestService = requestService,
       _authService = authService,
       _locationService = locationService,
       _imagePicker = imagePicker ?? ImagePicker();

  final RequestService _requestService;
  final AuthService _authService;
  final LocationService _locationService;
  final ImagePicker _imagePicker;

  File? photo;
  bool isSaving = false;
  String? errorMessage;

  Future<void> takePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (image != null) {
      photo = File(image.path);
      notifyListeners();
    }
  }

  Future<bool> submit({
    required String title,
    required String description,
  }) async {
    if (photo == null) {
      errorMessage = 'Tire uma foto para comprovar o ocorrido.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.currentUser?.uid ?? '';

      final results = await Future.wait<Object>([
        _locationService.currentPosition(),
        _requestService.uploadPhoto(photo: photo!, userId: userId),
      ]);

      final position = results[0] as Position;
      final photoUrl = results[1] as String;

      await _requestService.create(
        title: title,
        description: description,
        photoUrl: photoUrl,
        userId: userId,
        userName: _authService.currentUserName,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return true;
    } on LocationUnavailableException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível cadastrar a solicitação.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
