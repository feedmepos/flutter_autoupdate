import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'providers/app_id.dart';
import 'providers/url.dart';

class DownloadProgress {
  DownloadProgress(this.received, this.total, this.destination);

  final int received;
  final int total;
  final String destination;

  double get progress => received / total * 100;

  bool get completed => progress == 100;
}

class UpdateResult {
  UpdateResult(
      {required this.latestVersion,
      required this.downloadUrl,
      required this.releaseNotes,
      required this.releaseDate});

  final Version latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final String releaseDate;

  Future<StreamController<DownloadProgress>> initializeUpdate() async {
    var controller = StreamController<DownloadProgress>();
    if (Platform.isIOS) {
      await canLaunch(downloadUrl)
          ? await launch(downloadUrl)
          : throw Exception('Could not launch App Store url');

      /// So the progress will be completed
      /// 1/1*100 = 100%
      controller.add(DownloadProgress(1, 1, ""));
      return controller;
    } else if (Platform.isAndroid || Platform.isWindows) {
      var dir = await getApplicationDocumentsDirectory();
      var fileSuffix = Platform.isAndroid ? 'apk' : 'exe';
      var filePath = '${dir.path}/feedme_$latestVersion.$fileSuffix';
      var dio = Dio();
      dio.download(downloadUrl, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          controller.add(DownloadProgress(received, total, filePath));
        }
      });
      return controller;
    } else {
      throw Exception('Platform not supported');
    }
  }

// Future<bool> installUpdate(
//     {bool restartAfterInstall = true, bool silentUpdate = true}) async {}
}

/// Application [currentVersion]
///
/// Version changelog url [versionUrl]
///
/// Optional [forceAppId], providing it will force it to fetch update from iTunes App Store instead
class UpdateManager {
  UpdateManager(this.currentVersion,
      {required this.versionUrl, this.forceAppId});

  Version currentVersion;
  String versionUrl;
  int? forceAppId;

  /// Fetch update results filter by [countryCode] if [forceAppId] is provided
  ///
  /// [countryCode] is ISO 3166-1-alpha-2 country code
  ///
  /// Example: US, EU, UK, SG, MY
  Future<UpdateResult> checkUpdates({String countryCode = 'US'}) async {
    if (Platform.isIOS) {
      if (forceAppId != null) {
        return await IosAppId(forceAppId!, countryCode).fetchUpdate();
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
