import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import 'driverViewRouteScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapThatIncDrivers(driverList: []), // Bu örnekte driverList boş
    );
  }
}

class MapThatIncDrivers extends StatefulWidget {
  final List driverList;

  MapThatIncDrivers({required this.driverList});

  @override
  _MapThatIncDriversState createState() => _MapThatIncDriversState();
}

class _MapThatIncDriversState extends State<MapThatIncDrivers> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late Location _location;
  late LatLng _currentPosition;
  LatLng? startPoint;
  LatLng? destPoint;
  final TextEditingController _typeAheadController = TextEditingController();

  double? totalDistance;
  List<LatLng> routeCoordinates = [];

  String? selectedDriverName;
  LatLng? selectedDriverPosition;
  String? selectedDriverCarModel;
  String? selectedDriverNationalID;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _getCurrentLocation();
  }

  // Firebase Realtime Database referansı
  final DatabaseReference _database = FirebaseDatabase(databaseURL: "https://follow-the-txii-default-rtdb.firebaseio.com/").reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sürücü Konumları Haritası'),
        leading: IconButton(
          icon: Icon(Icons.directions),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RouteMapScreen(databaseReference: _database)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showRouteDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: selectedDriverName != null ? _buildDriverInfoDrawer() : Center(child: Text('Sürücü Seçin')),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(40.113835, 26.421846),
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                        hintText: 'Adres Ara',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await _getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['description']),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      _typeAheadController.text = suggestion['description'];
                      var placeId = suggestion['place_id'];
                      var details = await _getPlaceDetails(placeId);
                      setState(() {
                        destPoint = LatLng(details['lat'], details['lng']);
                      });
                      _controller.animateCamera(
                          CameraUpdate.newLatLng(destPoint!));
                      _markers.add(
                        Marker(
                          markerId: MarkerId('destination'),
                          position: destPoint!,
                          infoWindow: InfoWindow(
                            title: 'Seçilen Konum',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: 100,
                  color: Colors.blue,
                  child: Center(
                    child: Text('Container 1'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: 100,
                  color: Colors.red,
                  child: Center(
                    child: Text('Container 2'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: 20,
                  color: Colors.green,
                  child: Center(
                    child: Text('Container 3'),
                  ),
                ),
              ],
            ),
          ),
          if (routeCoordinates.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 15,
              right: 15,
              child: ElevatedButton(
                onPressed: () {
                  // Realtime Database'e rota bilgilerini yükleyin
                  _uploadRouteToDatabase();
                },
                child: Text('Rota Bilgisini Gönder'),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _updateMarkers();
  }

  void _updateMarkers() {
    if (widget.driverList.isNotEmpty) {
      for (var driver in widget.driverList) {
        if (driver.containsKey('Konum')) {
          double? latitude = driver['Konum']?['latitude'];
          double? longitude = driver['Konum']?['longitude'];
          String? name = driver['Ad Soyad'];
          String? carModel= driver['Araba Modeli'];
          String? nationalID= driver['TC Kimlik Numarası'];

          if (latitude != null && longitude != null && name != null) {
            _markers.add(
              Marker(
                markerId: MarkerId(latitude.toString() + longitude.toString()),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: name+carModel!,
                  snippet: 'Konum Bilgisi',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () {
                  setState(() {
                    selectedDriverName = name;
                    selectedDriverPosition = LatLng(latitude, longitude);
                    selectedDriverCarModel= carModel;
                    selectedDriverNationalID= nationalID;


                  });
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          }
        }
      }
      setState(() {});
    }
  }

  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var _locationData = await _location.getLocation();
    _currentPosition =
        LatLng(_locationData.latitude!, _locationData.longitude!);
    _controller.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: 'Mevcut Konumunuz',
          ),
        ),
      );
    });
  }

  void _createPolylines(LatLng start, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE',
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(start.toString() + destination.toString()),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ),
      );
      routeCoordinates = polylineCoordinates;
    });

    // Mesafeyi hesapla
    double distanceInMeters = await Geolocator.distanceBetween(
      start.latitude, start.longitude,
      destination.latitude, destination.longitude,
    );

    double distanceInKm = distanceInMeters / 1000;
    String distance = distanceInKm.toStringAsFixed(2);

    // Ücreti hesapla
    double openingPrice = 100;
    double kmPrice = 18;
    double indiBindiPrice = 100;
    double totalPrice = openingPrice + (distanceInKm * kmPrice) +
        indiBindiPrice;

    // Sonuçları güncelle
    setState(() {
      totalDistance = distanceInKm;
    });

    // Mesafeyi yazdır
    setState(() {
      distance = distance;
    });
  }

  Future<List> _getSuggestions(String query) async {
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String request = '$baseUrl?input=$query&key=AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE&components=country:tr';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['predictions'];
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    final String request = '$baseUrl?place_id=$placeId&key=AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      return {'lat': location['lat'], 'lng': location['lng']};
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void _showRouteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rota Oluştur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Başlangıç Noktası:'),
                subtitle: startPoint != null
                    ? Text(
                    'Enlem: ${startPoint!.latitude}, Boylam: ${startPoint!
                        .longitude}')
                    : Text('Güncel Konum'),
                trailing: IconButton(
                  icon: Icon(Icons.edit_location),
                  onPressed: () async {
                    var selectedLocation = await _selectLocation(
                        context, 'Başlangıç Noktası Seç');
                    if (selectedLocation != null) {
                      setState(() {
                        startPoint = selectedLocation;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Varış Noktası:'),
                subtitle: destPoint != null
                    ? Text('Enlem: ${destPoint!.latitude}, Boylam: ${destPoint!
                    .longitude}')
                    : Text('Seçilmedi'),
                trailing: IconButton(
                  icon: Icon(Icons.edit_location),
                  onPressed: () async {
                    var selectedLocation = await _selectLocation(
                        context, 'Varış Noktası Seç');
                    if (selectedLocation != null) {
                      setState(() {
                        destPoint = selectedLocation;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (startPoint != null && destPoint != null) {
                  _createPolylines(startPoint!, destPoint!);
                } else if (destPoint != null) {
                  _createPolylines(_currentPosition, destPoint!);
                }
              },
              child: Text('Rota Oluştur'),
            ),
          ],
        );
      },
    );
  }

  Future<LatLng?> _selectLocation(BuildContext context, String hintText) async {
    final ScrollController _scrollController = ScrollController();
    return showDialog<LatLng>(
      context: context,
      builder: (context) {
        final TextEditingController _searchController = TextEditingController();
        return AlertDialog(
          title: Text(hintText),
          content: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Adres Ara',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await _getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['description']),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    _searchController.text = suggestion['description'];
                    var placeId = suggestion['place_id'];
                    var details = await _getPlaceDetails(placeId);
                    Navigator.pop(
                        context, LatLng(details['lat'], details['lng'])
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _uploadRouteToDatabase() {
    if (routeCoordinates.isNotEmpty && selectedDriverName != null) {
      final routeData = {
        'driver_name': selectedDriverName,
        'National ID': selectedDriverNationalID,
        'start': {
          'latitude': routeCoordinates.first.latitude,
          'longitude': routeCoordinates.first.longitude,
        },
        'end': {
          'latitude': routeCoordinates.last.latitude,
          'longitude': routeCoordinates.last.longitude,
        },
        'coordinates': routeCoordinates.map((e) => {'latitude': e.latitude, 'longitude': e.longitude}).toList(),
        'total_distance': totalDistance,
      };

      _database.child('routes').push().set(routeData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rota başarıyla yüklendi!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rota yüklenirken hata oluştu: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen sürücü seçin ve rota oluşturun!')),
      );
    }
  }


  Widget _buildDriverInfoDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Sürücü Bilgisi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          title: Text('Ad Soyad: $selectedDriverName'),
        ),
        ListTile(
          title: Text('Enlem: ${selectedDriverPosition?.latitude}'),
        ),
        ListTile(
          title: Text('Boylam: ${selectedDriverPosition?.longitude}'),
        ),
      ],
    );
  }
}
