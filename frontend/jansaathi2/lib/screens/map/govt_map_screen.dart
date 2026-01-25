import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GovtMapScreen extends StatefulWidget {
  const GovtMapScreen({super.key});

  @override
  State<GovtMapScreen> createState() => _GovtMapScreenState();
}

class _GovtMapScreenState extends State<GovtMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // Default position (Kerala)
  LatLng _currentPosition = const LatLng(10.8505, 76.2711);
  bool _isLoading = true;

  // IMPORTANT: Secure this key in production
  final String googleApiKey = "YOUR_GOOGLE_API_KEY";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Location permissions are permanently denied.");
      return;
    }

    // ✅ CORRECT FIX: use locationSettings (NOT desiredAccuracy)
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 14),
    );

    _loadNearbyGovtPlaces();
  }

  Future<void> _loadNearbyGovtPlaces() async {
    final types = ["police", "hospital", "local_government_office"];
    final keywords = ["Akshaya", "Janasena"];

    for (final type in types) {
      _fetchPlaces(type: type);
    }
    for (final keyword in keywords) {
      _fetchPlaces(keyword: keyword);
    }
  }

  Future<void> _fetchPlaces({String? type, String? keyword}) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${_currentPosition.latitude},${_currentPosition.longitude}"
        "&radius=5000"
        "&keyword=${keyword ?? ""}"
        "&type=${type ?? ""}"
        "&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "OK" && mounted) {
          for (final place in data["results"]) {
            final LatLng pos = LatLng(
              place["geometry"]["location"]["lat"],
              place["geometry"]["location"]["lng"],
            );

            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId(place["place_id"]),
                  position: pos,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    type == "hospital"
                        ? BitmapDescriptor.hueRed
                        : BitmapDescriptor.hueAzure,
                  ),
                  infoWindow: InfoWindow(
                    title: place["name"],
                    snippet: place["vicinity"] ?? "",
                  ),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Government Places"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
