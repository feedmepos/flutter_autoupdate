import 'package:flutter_updater/flutter_updater.dart';

abstract class Provider {
  Future<UpdateResult?> fetchUpdate();
  String buildUpdateUrl();
}
