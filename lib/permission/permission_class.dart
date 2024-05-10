import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Konum iznini kontrol etmek için bu fonksiyonu kullanın.
  static Future<bool> checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // Konum izni istemek için bu fonksiyonu kullanın.
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }


// Diğer izinleri kontrol etmek ve istemek için benzer fonksiyonlar eklenebilir.
}
