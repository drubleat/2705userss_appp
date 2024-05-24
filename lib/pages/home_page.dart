import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:users_app/pages/menu_page.dart';
import 'package:users_app/pages/searc_page.dart';

import '../widgets/animations.dart';


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

  final Set<Polyline> _polylines = {};
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  bool isDrawerOpen = false;
  int _selectedIndex = 1;


  @override
  Widget build(BuildContext context) {
    // Klavye durumunu dinleme
    final keyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisibility) {
      // Klavye açıldığında alt barın yüksekliğini 0 olarak ayarlayın
    } else {
      // Klavye kapandığında alt barın varsayılan yüksekliğini ayarlayın
    }

    return GestureDetector(
      // Boş bir yere tıklandığında klavyeyi gizlemek için GestureDetector kullanın
      onTap: () {
        FocusScope.of(context).unfocus(); // Klavyeyi gizle
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.normal,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),


            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDrawerOpen = !isDrawerOpen;
                      });
                    },
                    child: GNav(
                      backgroundColor: Colors.white,
                      color: Colors.black,
                      activeColor: Colors.black,
                      tabBackgroundColor: Colors.amber.shade300,
                      gap: 4,
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        // Search butonuna tıklandığında yönlendirme işlemi
                        if (index == 0) {
                          setState(() {
                            _selectedIndex = index; // Seçili indeksi güncelleyin
                          });
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20), // Sol üst köşe
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                height: 850,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _startLocationController,
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(color: Colors.amber), // Etiket rengi
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Çerçeve köşeleri
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Etkin olmayan çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Etkin olmayan çerçeve köşeleri
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Odaklanılan çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Odaklanılan çerçeve köşeleri
                                          ),
                                          hintText: 'Varış Noktası',
                                          hintStyle: const TextStyle(color: Colors.amber), // Hint text rengi
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _endLocationController,
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(color: Colors.amber), // Etiket rengi
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Çerçeve köşeleri
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Etkin olmayan çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Etkin olmayan çerçeve köşeleri
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.amber), // Odaklanılan çerçeve rengi
                                            borderRadius: BorderRadius.circular(10), // Odaklanılan çerçeve köşeleri
                                          ),
                                          hintText: 'Varış Noktası',
                                          hintStyle: const TextStyle(color: Colors.amber), // Hint text rengi
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          _createRoute();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(36),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                            child: Text(
                                              'Rota Oluştur',
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                      padding: const EdgeInsets.all(20),
                      tabBorderRadius: 0,
                      tabs: const [
                        GButton(
                          icon: Icons.route,
                          text: 'Rota',
                        ),
                        GButton(
                          icon: Icons.home,
                          text: 'Ana Menü',
                        ),
                        GButton(
                          icon: Icons.local_taxi_outlined,
                          text: 'İlan',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        // Arama butonuna basıldığında yapılacak işlemler
                      },
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(SlideDownRoute(widget: const SearchPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: const Text(
                            'Arama yapın',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Navigator.of(context).push(SlideRightRoute(widget: const NavBar()),

                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 300,
              left: 350,
              child: FloatingActionButton(
                backgroundColor: Colors.amber, // Gri arka plan rengi
                child: const Icon(Icons.location_searching, color: Colors.black),
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
            ),
          ],
        ),
      ),
    );



  }


















  bool isMapLoading = true; // Harita yükleme durumunu takip etmek için bir boolean değişken

  @override
  void initState() {
    super.initState();

    // Google Haritalar bileşeni yüklendiğinde yükleme durumunu false olarak güncelle
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isMapLoading = false;
      });
    });
  }









  void _createRoute() {
    String startLocation = _startLocationController.text;
    String endLocation = _endLocationController.text;

    if (startLocation.isNotEmpty && endLocation.isNotEmpty) {
      _getPolyline(startLocation, endLocation).then((polylineCoordinates) {
        if (polylineCoordinates.isNotEmpty) {
          setState(() {
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.red,
              width: 5,
            ));

            // Rota uzunluğunu ölçmek ve fiyatı hesaplamak
            double distanceInKm = _calculateDistance(polylineCoordinates);
            double price = distanceInKm * 2; // Fiyat hesaplama formülü, mesafeyi 1.5 ile çarparak

            // Rotanın başlangıç ve bitiş noktalarını içeren bir LatLngBounds oluştur
            LatLngBounds bounds = LatLngBounds(
              southwest: polylineCoordinates.reduce((value, element) => LatLng(
                value.latitude < element.latitude ? value.latitude : element.latitude,
                value.longitude < element.longitude ? value.longitude : element.longitude,
              )),
              northeast: polylineCoordinates.reduce((value, element) => LatLng(
                value.latitude > element.latitude ? value.latitude : element.latitude,
                value.longitude > element.longitude ? value.longitude : element.longitude,
              )),
            );

            // Harita kontrolcüsünü al ve rotayı göstermek için haritayı hareket ettir
            _controller.future.then((controller) {
              controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            });

            // Kullanıcıya fiyatı göstermek için bir ileti göster
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Mesafe: $distanceInKm fiyat: $price tl"),

            ));
          });
        } else {
          // Kullanıcıya uygun bir hata mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Route not found. Please check your locations."),
          ));
        }
      }).catchError((error) {
        print('Rota olutşturulamadı: $error');
      });
    }
  }

// Rota uzunluğunu hesaplamak için kullanılan yardımcı fonksiyon
  double _calculateDistance(List<LatLng> polylineCoordinates) {
    double totalDistance = 0.0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    return totalDistance;
  }

// İki koordinat arasındaki mesafeyi hesaplamak için kullanılan yardımcı fonksiyon
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  } //rota oluşturma işlemleri burada yapılıyor.

  Future<List<LatLng>> _getPolyline(String startLocation, String endLocation) async {
    const apiKey = "AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE";
    final startLatLng = await _getLatLngFromAddress(startLocation);
    final endLatLng = await _getLatLngFromAddress(endLocation);

    final url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${startLatLng.latitude},${startLatLng.longitude}"
        "&destination=${endLatLng.latitude},${endLatLng.longitude}"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<LatLng> polylineCoordinates = [];
      final routes = decoded['routes'];
      for (final route in routes) {
        final points = route['overview_polyline']['points'];
        final List<LatLng> decodedPolyline = decodePolyline(points).cast<LatLng>();
        polylineCoordinates.addAll(decodedPolyline);
      }
      return polylineCoordinates;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    const apiKey = "AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE";
    final url = "https://maps.googleapis.com/maps/api/geocode/json?"
        "address=$address"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final results = decoded['results'];
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    throw Exception('Failed to get coordinates for address: $address');
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
}


