import 'package:geocoding/geocoding.dart';

Future<String> getPlaceFromCoordinates(double lat, double lon) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    Placemark place = placemarks[0];

    // Trả về tên Quận/Huyện + Thành phố
    return '${place.subAdministrativeArea}, ${place.administrativeArea}';
  } catch (e) {
    return 'Không xác định địa điểm';
  }
}
