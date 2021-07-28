import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'core/app_id.dart';

class UpdateResult {
  UpdateResult(
      {required this.isUpdateAvailable,
      required this.latestVersion,
      required this.directUrl});

  final bool isUpdateAvailable;
  final Version latestVersion;
  final String directUrl;

  Future<void> initializeUpdate() async {
    if (Platform.isIOS) {
      await canLaunch(directUrl)
          ? await launch(directUrl)
          : throw Exception('Could not launch App Store url');
    }
    if (Platform.isAndroid || Platform.isWindows) {}
  }
}

class UpdateManager {
  UpdateManager(this.currentVersion, {this.iosAppId});

  Version currentVersion;
  int? iosAppId;

  Future<UpdateResult> checkUpdates() async {
    if (Platform.isIOS) {
      if (iosAppId != null) {
        var ios = Ios(iosAppId!);
        var latestVersion = await ios.getVersion();
        return UpdateResult(
            isUpdateAvailable: latestVersion > currentVersion,
            latestVersion: latestVersion,
            directUrl: buildiOSUrl());
      } else {
        throw Exception("iOS App Id is required to check for updates");
      }
    }
    if (Platform.isAndroid || Platform.isWindows) {
      /// TODO
    }
    throw Exception("Platform not supported");
  }

  String buildiOSUrl() {
    return 'itms-apps://itunes.apple.com/app/$iosAppId';
  }
}
