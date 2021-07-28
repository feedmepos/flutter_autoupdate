import 'package:flutter_updater/flutter_updater.dart';

abstract class Updater {
  Future<UpdateResult> fetchUpdate();
  String buildUpdateUrl();
}
