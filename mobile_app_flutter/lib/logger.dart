import 'package:logging/logging.dart';

final Logger _logger = Logger('getMapLocation');

void setupLogger() {
  Logger.root.level = Level.ALL; // Set log level to ALL (or desired level)
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
