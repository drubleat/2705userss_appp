import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMapScreen extends StatefulWidget {
  final DatabaseReference databaseReference;

  RouteMapScreen({required this.databaseReference});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState(databaseReference);
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController _controller;
  final TextEditingController _nationalIDController = TextEditingController();
  final Map<String, Polyline> _routes = {};
  final DatabaseReference _databaseReference;

  _RouteMapScreenState(this._databaseReference);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rota Haritası'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nationalIDController,
            decoration: InputDecoration(labelText: 'TC Kimlik Numaranız'),
          ),
          ElevatedButton(
            onPressed: _getAndDrawRoute,
            child: Text('Rota Çiz'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              polylines: _routes.values.toSet(),
              initialCameraPosition: CameraPosition(
                target: LatLng(40.113835, 26.421846),
                zoom: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _getAndDrawRoute() {
    String nationalID = _nationalIDController.text;
    _getRouteForDriver(nationalID);
  }

  void _getRouteForDriver(String nationalID) {
    _databaseReference
        .child('routes')
        .orderByChild('National ID')
        .equalTo(nationalID)
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        setState(() {
          // Clear the old routes
          _routes.clear();

          Map<dynamic, dynamic> routes = snapshot.value as Map<dynamic,
              dynamic>;
          routes.forEach((key, value) {
            var route = value as Map<dynamic, dynamic>;
            var coordinates = route['coordinates'] as List<dynamic>;
            List<LatLng> polylineCoordinates = coordinates.map<LatLng>((coord) {
              double lat = coord['latitude'];
              double lng = coord['longitude'];
              return LatLng(lat, lng);
            }).toList();
            _routes[key] = Polyline(
              polylineId: PolylineId(key),
              color: Colors.blue,
              points: polylineCoordinates,
              width: 5,
            );
          });
        });
      } else {
        // If no route found, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Belirtilen sürücüye ait rota bulunamadı.'),
        ));
      }
    }, onError: (error) {
      // If an error occurs, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Rota bilgilerini alırken bir hata oluştu: $error'),
      ));
    });
  }}