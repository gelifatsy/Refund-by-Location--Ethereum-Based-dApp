import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

final _logger = Logger('getMapLocation');

Future<void> getMapLocation(String lat_1, String lon_1) async {
  if (lat_1 == "0.00" && lon_1 == "0.00") {
    _logger.fine('No data yet');
  } else {
    // Replace with your actual logic for handling latitude and longitude

    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat_1,$lon_1";
    final String appleMapsUrl = "https://maps.apple.com/?q=$lat_1,$lon_1";

    Uri googleUri = Uri.parse(googleMapsUrl);
    Uri appleUri = Uri.parse(appleMapsUrl);

    if (await canLaunchUrl(googleUri)) {
      await launch(googleUri.toString());
    }
    if (await canLaunchUrl(appleUri)) {
      await launch(appleUri.toString(), forceSafariVC: false);
    } else {
      _logger.severe("Couldn't launch URL");
    }
  }
}
