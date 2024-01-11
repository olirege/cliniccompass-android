import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

Future<LocationData?> getCurrentLocation() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  _locationData = await location.getLocation();
  return _locationData;
}

Future<void> openMapWithDirections(double startLat, double startLng, double endLat, double endLng) async {
  String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving';
  Uri googleUri = Uri.parse(googleUrl);
  if (await canLaunchUrl(googleUri)) {
    await launchUrl(googleUri);
  } else {
    throw 'Could not open the map.';
  }
}

double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
  const double radiusOfEarth = 6371000; // Radius of the Earth in meters
  double latDistance = _toRadians(endLat - startLat);
  double lngDistance = _toRadians(endLng - startLng);

  double a = sin(latDistance / 2) * sin(latDistance / 2)
      + cos(_toRadians(startLat)) * cos(_toRadians(endLat))
      * sin(lngDistance / 2) * sin(lngDistance / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return radiusOfEarth * c; // Distance in meters
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

_formatDistance(double distance) {
  if (distance < 1000) {
    return "${distance.toStringAsFixed(0)} m";
  } else {
    return "${(distance / 1000).toStringAsFixed(1)} km";
  }
}

Future<String> showDistanceToClinic(double clinicLat, double clinicLng) async {
  try {
    LocationData? currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      double userLat = currentLocation.latitude!;
      double userLng = currentLocation.longitude!;
      double distance = calculateDistance(userLat, userLng, clinicLat, clinicLng);
      String distanceString = distance.isNaN ? "? km" : _formatDistance(distance);
      return distanceString;
    } else {
      return "? km";
    }
  } catch (e) {
    return "? km";
  }
}