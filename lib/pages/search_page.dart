import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  List<String> _locations = [];
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(40.113835, 26.421846);
  final MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isListViewVisible = false;
  late loc.LocationData _userLocation;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocusNode.requestFocus());
    _getUserLocation();

    // _markers ve _polylines değişkenlerini oluşturduk
    _markers = {};
    _polylines = {};
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: _currentMapType,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true, // Kullanıcının konumunu haritada göstermek için eklenen özellik
              myLocationButtonEnabled: true,
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: _searchLocations,
                        focusNode: _searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Arama yapın',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        // Navigator.of(context).push(SlideRightRoute(widget: const NavBar()));
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isListViewVisible)
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isListViewVisible = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: MediaQuery.of(context).size.height * 0.3,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: _locations.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_locations[index], style: const TextStyle(color: Colors.black)),
                            onTap: () {
                              _markLocation(_locations[index]);
                              setState(() {
                                _isListViewVisible = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              child: ElevatedButton(
                onPressed: () {
                  if (_markers.isNotEmpty) {
                    _createRoute(_userLocation, _markers.first.position);
                  }
                },
                child: const Text('Rota Oluştur'),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _fetchAndMarkDriverLocations,
                child: const Text('Sürücü Konumları'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchLocations(String query) async {
    if (query.isNotEmpty) {
      const apiKey = "API_KEY_HERE";
      final encodedQuery = Uri.encodeQueryComponent(query, encoding: utf8);
      final url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&key=$apiKey";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = decoded['results'];
        List<String> locations = [];
        for (final result in results) {
          locations.add(result['name']);
        }
        setState(() {
          _locations = locations;
          _isListViewVisible = true;
        });
      } else {
        print('Failed to search locations');
      }
    } else {
      setState(() {
        _locations.clear();
        _isListViewVisible = false;
      });
    }
  }

  void _markLocation(String location) async {
    final LatLng latLng = await _getLatLngFromPlaceName(location);
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );

    _addMarker(location, latLng);
  }

  void _addMarker(String location, LatLng latLng) async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(location),
          position: latLng,
          infoWindow: InfoWindow(
            title: location,
            snippet: 'Konumunuz burada',
          ),
        ),
      );
    });
  }

  Future<LatLng> _getLatLngFromPlaceName(String placeName) async {
    const apiKey = "API_KEY_HERE";
    final url = "https://maps.googleapis.com/maps/api/geocode/json?address=$placeName&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final results = decoded['results'];
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    throw Exception('Failed to get coordinates for place: $placeName');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
  }

  Future<void> _getUserLocation() async {
    final loc.Location location = loc.Location();

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {
      _userLocation = locationData;
    });
  }

  void _createRoute(loc.LocationData start, LatLng destination) async {
    // Başlangıç konumu ve hedef konumu alın
    LatLng startLatLng = LatLng(start.latitude!, start.longitude!);
    LatLng destLatLng = destination;

    // Rota çizgisi için koordinat listesi
    List<LatLng> polylineCoordinates = [];

    // Başlangıç ve hedef konumlar arasında bir rota almak için Google Directions API kullanın
    const apiKey = "API_KEY_HERE";
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startLatLng.latitude},${startLatLng.longitude}&destination=${destLatLng.latitude},${destLatLng.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map values = json.decode(response.body);
      values["routes"].forEach((route) {
        // Rota ayrıntılarını al
        List<dynamic> legs = route["legs"];
        for (var leg in legs) {
          // Her adımı al
          List<dynamic> steps = leg["steps"];
          for (var step in steps) {
            // Adımın polyline kısmını al ve her bir koordinatı çizgiye ekle
            String polyline = step["polyline"]["points"];
            List<LatLng> decodedPolyline = decodePolyline(polyline);
            polylineCoordinates.addAll(decodedPolyline);
          }
        }
      });

      // Rota çizgisini haritaya eklemek için bir polyline oluşturun
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId("Destination"),
            position: destLatLng,
            infoWindow: const InfoWindow(
              title: "Destination",
            ),
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId("Start"),
            position: startLatLng,
            infoWindow: const InfoWindow(
              title: "Start",
            ),
          ),
        );
        _markers.addAll(
          [
            Marker(
              markerId: const MarkerId("Start"),
              position: startLatLng,
            ),
            Marker(
              markerId: const MarkerId("Destination"),
              position: destLatLng,
            ),
          ],
        );
        Polyline polyline = Polyline(
          polylineId: const PolylineId("poly"),
          color: Colors.red,
          points: polylineCoordinates,
          width: 3,
        );
        _polylines.add(polyline);
      });
    } else {
      print("Failed to fetch directions");
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _fetchAndMarkDriverLocations() async {
    // Realtime Database'den sürücü konumlarını al
    final response = await http.get(Uri.parse('https://follow-the-txii-default-rtdb.firebaseio.com/konum.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        _addDriverMarkers(Map<String, dynamic>.from(data));
      } else {
        print('Driver locations are null');
      }
    } else {
      print('Failed to fetch driver locations: ${response.statusCode}');
    }
  }

  void _addDriverMarkers(Map<String, dynamic> driverLocations) {
    // Sürücü konumlarını al ve haritada işaretleyin
    driverLocations.forEach((driverId, locationData) {
      double lat = locationData['lat'];
      double lng = locationData['lng'];

      LatLng driverLatLng = LatLng(lat, lng);

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(driverLatLng, 14),
      );

      _markers.add(
        Marker(
          markerId: MarkerId(driverId),
          position: driverLatLng,
          infoWindow: InfoWindow(
            title: 'Sürücü $driverId',
            snippet: 'Konumunuz burada',
          ),
        ),
      );
    });
  }
}
