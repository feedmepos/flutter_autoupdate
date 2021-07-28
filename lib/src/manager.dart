import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'providers/app_id.dart';
import 'providers/url.dart';

class UpdateProgress {
  UpdateProgress(this.received, this.total);

  final double received;
  final double total;

  double get progress => (received / total) * 100;

  bool get completed => progress == 100;
}

class UpdateResult {
  UpdateResult({required this.latestVersion, required this.directUrl});

  final Version latestVersion;
  final String directUrl;

  Future<Stream<UpdateProgress>> initializeUpdate(
      {bool restartAfterUpdate = true, bool silentUpdate = true}) async {
    var controller = StreamController<UpdateProgress>();
    if (Platform.isIOS) {
      await canLaunch(directUrl)
          ? await launch(directUrl)
          : throw Exception('Could not launch App Store url');
      return controller.stream;
    } else if (Platform.isAndroid || Platform.isWindows) {
      var tempDir = await getTemporaryDirectory();
      var tempPath = tempDir.path;
    } else {
      throw Exception('Platform not supported');
    }
  }
}

/// Application [currentVersion]
///
/// Version changelog url [versionUrl]
///
/// Optional iOS app id, providing it will ignore versionUrl for iOS update check [forceAppId]
class UpdateManager {
  UpdateManager(this.currentVersion,
      {required this.versionUrl, this.forceAppId});

  Version currentVersion;
  String versionUrl;
  int? forceAppId;

  Future<UpdateResult> checkUpdates() async {
    if (Platform.isIOS) {
      if (forceAppId != null) {
        return await IosAppId(forceAppId!).fetchUpdate();
      } else {
        return await Url(versionUrl).fetchUpdate();
      }
    } else if (Platform.isAndroid || Platform.isWindows) {
      return await Url(versionUrl).fetchUpdate();
    } else {
      throw Exception('Platform not supported');
    }
  }
}
