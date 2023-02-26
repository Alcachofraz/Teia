import 'package:logger/logger.dart';

class Logs {
  static final Logger logger = Logger();

  static d(Object object) {
    logger.d('$object');
  }

  static e(Object object) {
    logger.e('$object');
  }
}
