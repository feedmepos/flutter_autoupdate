import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'providers/app_id.dart';
import 'providers/url.dart';

typedef FilePath = String;

/// Stream Event
///
/// Download [receivedBytes] size
///
/// Download [totalBytes] size
///
/// Download absolute [path]
class DownloadProgress {
  DownloadProgress(this.receivedBytes, this.totalBytes, {required this.path});

  final int receivedBytes;
  final int totalBytes;
  final FilePath path;

  double get progress => receivedBytes / totalBytes * 100;

  bool get completed => progress == 100;

  String toPrettyMB(int bytes, {int decimalPoint = 2}) {
    var mb = bytes / 1024 / 1024;
    return '${mb.toStringAsFixed(decimalPoint)}MB';
  }
}

/// Update results fetched from App Store/custom version URL
///
/// Application [latestVersion]
///
/// Application [downloadUrl]
///
/// Application [releaseNotes]
///
/// Application [releaseDate]
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
      /// So the progress will be completed
      /// 1/1*100 = 100%
      controller.add(DownloadProgress(1, 1, path: downloadUrl));
      return controller;
    } else if (Platform.isAndroid || Platform.isWindows) {
      var dir = await getTemporaryDirectory();
      var fileSuffix = Platform.isAndroid ? 'apk' : 'exe';
      var filePath = '${dir.path}/feedme_$latestVersion.$fileSuffix';
      var dio = Dio();
      dio.download(downloadUrl, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          controller.add(DownloadProgress(received, total, path: filePath));
        }
      });
      return controller;
    } else {
      throw Exception('Platform not supported');
    }
  }

  /// Install/navigate to the respective file on OS
  ///
  /// iOS: Launch URL(App Store Url Scheme)
  ///
  /// Android: apk
  ///
  /// Windows: exe/msix
  ///
  /// Application/Installer/App Store [uri]
  ///
  /// [autoExit] parent process, only applies to Windows
  Future<void> runUpdate(FilePath uri,
      {bool autoExit = false, int exitDelay = 5000}) async {
    if (Platform.isIOS) {
      await canLaunch(downloadUrl)
          ? await launch(downloadUrl)
          : throw Exception("Fail to launch App Store url");
    }
    if (Platform.isAndroid) {}
    if (Platform.isWindows) {
      // Start the process using Windows shell instead of our parent process.
      // A detached process has no connection to its parent,
      // and can keep running on its own when the parent dies
      try {
        await Process.start(uri, [],
            runInShell: true, mode: ProcessStartMode.detached);
        if (autoExit) {
          await Future.delayed(Duration(milliseconds: exitDelay));
          exit(0);
        }
      } on Exception catch (e) {
        throw Exception("Failed to execute the file. Error: $e");
      }
    }
  }
}

/// Application [currentVersion]
///
/// Version changelog url [versionUrl]
///
/// Optional [appId], providing it will force it to fetch update from iTunes App Store instead
class UpdateManager {
  UpdateManager(this.currentVersion, {this.versionUrl, this.appId});

  Version currentVersion;
  String? versionUrl;
  int? appId;

  /// Fetch update results filter by [countryCode] if [appId] is provided
  ///
  /// [countryCode] is ISO 3166-1-alpha-2 country code
  ///
  /// Example: US, EU, UK, SG, MY
  Future<UpdateResult> checkUpdates({String countryCode = 'US'}) async {
    if (Platform.isIOS) {
      if (appId != null) {
        return await IosAppId(appId!, countryCode).fetchUpdate();
      } else if (versionUrl != null) {
        return await Url(versionUrl!).fetchUpdate();
      } else {
        throw Exception('One of the parameters must be provided for iOS');
      }
    } else if (Platform.isAndroid || Platform.isWindows) {
      assert(versionUrl != null,
          'versionUrl must not be null for the current platform.');
      return await Url(versionUrl!).fetchUpdate();
    } else {
      throw Exception('Platform not supported');
    }
  }
}
