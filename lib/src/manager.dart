import 'dart:io';
import '../flutter_updater.dart';
import 'package:version/version.dart';

class UpdateResult {
  UpdateResult(this.isUpdateAvailable, this.latestVersion);

  final bool isUpdateAvailable;
  final Version latestVersion;
}

class UpdateManager {
  UpdateManager(this.currentVersion, {this.iosAppId});

  Version currentVersion;
  String? iosAppId;
  String? apkUrl;

  Future<UpdateResult?> checkUpdates() async {
    if (iosAppId != null) {
      var ios = Ios(iosAppId!);
      var latestVersion = await ios.getVersion();
      if (latestVersion != null) {
        return UpdateResult(latestVersion > currentVersion, latestVersion);
      }
    }
    return null;
  }
}
