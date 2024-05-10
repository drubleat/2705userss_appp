import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.113835, 26.421846),
    zoom: 14,
  );

  final List<Marker> myMarker = [
    const Marker(
      markerId: MarkerId('first'),
      position: LatLng(40.113835, 26.421846),
      infoWindow: InfoWindow(
        title: 'My Position',
      ),
    ),
    const Marker(
      markerId: MarkerId('second'),
      position: LatLng(40.117707, 26.409751),
      infoWindow: InfoWindow(
        title: 'Second Place',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: SafeArea(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal,
              markers: Set<Marker>.of(myMarker),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.location_searching),
        onPressed: () async {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(40.117707, 26.409751),
                zoom: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}
