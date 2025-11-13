import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  GoogleMapController? mapController;
  LatLng? selectedPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  LatLng _initialPosition = const LatLng(36.752887, 3.042048); // Alger par défaut

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedPosition = position;
    });
  }

  void _confirmSelection() {
    if (selectedPosition != null) {
      Navigator.pop(context, selectedPosition);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Location"),
        backgroundColor: Colors.red,
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12,
        ),
        onMapCreated: (controller) => mapController = controller,
        onTap: _onMapTapped,
        markers: selectedPosition == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: selectedPosition!,
                ),
              },
        myLocationEnabled: true,
      ),
    );
  }
}
