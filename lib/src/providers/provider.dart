import 'package:flutter_autoupdate/flutter_autoupdate.dart';

abstract class Provider {
  Future<UpdateResult?> fetchUpdate();
  String buildUpdateUrl();
}
