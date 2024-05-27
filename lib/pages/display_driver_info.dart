import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:users_app/pages/drivers_current_locations_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(displayDriverInfo());
}

class displayDriverInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Realtime Database Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DriverListScreen(),
    );
  }
}

class DriverListScreen extends StatefulWidget {
  @override
  _DriverListScreenState createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final databaseReference = FirebaseDatabase(databaseURL: "https://follow-the-txii-default-rtdb.firebaseio.com/").reference();
  List<Map<dynamic, dynamic>> driverList = [];

  @override
  void initState() {
    super.initState();
    _getDrivers();
  }

  void _getDrivers() async {
    DatabaseReference ref = databaseReference.child('ilan açan sürücüler');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> drivers = Map<dynamic, dynamic>.from(snapshot.value as Map);
      List<Map<dynamic, dynamic>> tempList = [];
      drivers.forEach((key, value) {
        tempList.add(Map<dynamic, dynamic>.from(value));
      });
      setState(() {
        driverList = tempList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sürücü Listesi'),
      ),
      body: ListView.builder(
        itemCount: driverList.length,
        itemBuilder: (context, index) {
          return FutureBuilder<String?>(
            future: GeocodingService.getAddress(
              driverList[index]['Konum']['latitude'],
              driverList[index]['Konum']['longitude'],
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text('Yükleniyor...'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text('Hata: ${snapshot.error}'),
                );
              } else {
                return ListTile(
                  title: Text(driverList[index]['Ad Soyad']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Araba Modeli: ${driverList[index]['Araba Modeli']}'),
                      Text('Plaka\'nın son 2 rakamı: ${driverList[index]['Araba Plakasının Son 2 Hanesi']}'),
                      Text('Şehir Bilgisi: ${driverList[index]['Şehir Bilgisi']}'),
                      Text('Konum Bilgisi : ${snapshot.data ?? 'Bilinmiyor'}'),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapThatIncDrivers(driverList: driverList)),
          );
        },
        child: Icon(Icons.map),
      ),
    );
  }
}

class GeocodingService {
  static Future<String?> getAddress(double latitude, double longitude) async {
    final apiKey = "AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE"; // Google Maps Geocoding API key
    final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = decoded['results'];
        if (results.isNotEmpty) {
          return results[0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    return null;
  }
}


