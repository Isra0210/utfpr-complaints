import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationUnavailableException implements Exception {
  LocationUnavailableException(this.message);

  final String message;
}

class LocationService {
  Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw LocationUnavailableException('Ative a localização do dispositivo.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationUnavailableException('Permissão de localização negada.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      throw LocationUnavailableException(
        'Não foi possível obter a localização. Tente novamente.',
      );
    }
  }
}
