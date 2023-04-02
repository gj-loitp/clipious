import 'package:get/get.dart';
import 'package:logging/logging.dart';

import '../globals.dart';
import '../models/db/server.dart';
import '../utils.dart';

class WelcomeWizardController extends GetxController {
  static WelcomeWizardController? to() => safeGet();
  Server? selected;
  final log = Logger('WelcomeWizard');

  getSelectedServer() {
    try {
      selected = db.getCurrentlySelectedServer();
      log.info('selected server ${selected?.url}');
    } catch (err) {
      selected = null;
      log.info('We don\'t have a server');
    }
    update();
  }
}