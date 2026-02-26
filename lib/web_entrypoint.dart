import 'package:flutter_application_2/main.dart' as entrypoint;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  entrypoint.main();
}
