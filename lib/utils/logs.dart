import 'package:logger/logger.dart';

class Logs {
  static final Logger _logger = Logger();

  static d(Object object) {
    _logger.d('$object');
  }

  static e(Object object) {
    _logger.e('$object');
  }
}
