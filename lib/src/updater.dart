import 'dart:async';
import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
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

  static DownloadProgress completedEvent(FilePath path) {
    return DownloadProgress(1, 1, path: path);
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
      required this.releaseDate,
      this.sha512});

  final Version latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final String releaseDate;
  final String? sha512;

  factory UpdateResult.fromJson(Map<String, dynamic> json) {
    var version = json["version"];
    var url = json["url"];
    var rNotes = json["releaseNotes"];
    var rDate = json["releaseDate"];
    var checksum = json["sha512"];
    return UpdateResult(
        latestVersion: Version.parse(version),
        downloadUrl: url,
        releaseNotes: rNotes,
        releaseDate: rDate,
        sha512: checksum);
  }

  Map<String, dynamic> toJson() => {
        "version": latestVersion.toString(),
        "downloadUrl": downloadUrl,
        "releaseNotes": releaseNotes,
        "releaseDate": releaseDate,
        "sha512": sha512
      };

  Future<StreamController<DownloadProgress>> initializeUpdate(
      {String? downloadPath}) async {
    if (Platform.isIOS) {
      await runUpdate(downloadUrl);
      throw Exception(
          "initializeUpdate is not supported on iOS. You should use runUpdate instead");
    } else if (Platform.isAndroid || Platform.isWindows) {
      var dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getTemporaryDirectory();
      var urlContent = downloadUrl.split('/');
      if (urlContent.isEmpty) {
        throw Exception("The download URL may be invalid.");
      }
      // Split a URL and retrieve the file name
      var filePath =
          '${downloadPath ?? dir!.path}/${urlContent[urlContent.length - 1]}';
      return initDownload(filePath);
    } else {
      throw Exception('Platform not supported');
    }
  }

  Future<StreamController<DownloadProgress>> initDownload(FilePath path) async {
    var controller = StreamController<DownloadProgress>();
    var file = File(path);
    if (await file.exists()) {
      var bytes = await file.readAsBytes();
      var sha512 = crypto.sha512.convert(bytes);
      // Checksum is identical
      // Emit completed event
      if (sha512.toString() == this.sha512) {
        controller.add(DownloadProgress.completedEvent(path));
      } else {
        await _beginDownload(controller, path);
      }
    } else {
      await _beginDownload(controller, path);
    }
    return controller;
  }

  Future<void> _beginDownload(
      StreamController controller, FilePath path) async {
    var dio = Dio();
    await dio.download(downloadUrl, path, onReceiveProgress: (received, total) {
      if (total != -1) {
        controller.add(DownloadProgress(received, total, path: path));
      }
    });
  }

  /// Install/navigate to the respective file on OS
  ///
  /// iOS: Launch URL(App Store Url Scheme)
  ///
  /// Android: apk
  ///
  /// Windows: exe/msix/zip
  ///
  /// Application/Installer/App Store [uri]
  ///
  /// [autoExit] parent process, only applies to Windows
  Future<void> runUpdate(FilePath uri,
      {bool autoExit = false,
      FilePath? exractPathUri,
      String? executableFileName,
      int exitDelay = 3000}) async {
    if (Platform.isIOS) {
      await canLaunch(downloadUrl)
          ? await launch(downloadUrl)
          : throw Exception("Fail to launch App Store url");
    } else if (Platform.isAndroid) {
      await AppInstaller.installApk(uri);
    } else if (Platform.isWindows) {
      // Start the process using Windows shell instead of our parent process.
      // A detached process has no connection to its parent,
      // and can keep running on its own when the parent dies
      try {
        if (uri.endsWith(".zip")) {
          await extractFileToDisk(uri, exractPathUri!);
        }
        await Process.start(
            exractPathUri != null
                ? "${exractPathUri}\\${executableFileName!}"
                : uri,
            [],
            runInShell: true,
            mode: ProcessStartMode.detached);

        if (autoExit) {
          await Future.delayed(Duration(milliseconds: exitDelay));
          exit(0);
        }
      } on Exception catch (e) {
        throw Exception("Failed to execute the file. Error: $e");
      }
    } else {
      throw Exception("Platform not supported");
    }
  }
}

/// Application [currentVersion]
///
/// Optional [versionUrl], for Android & Windows
///
/// Optional [appId], for iOS
class UpdateManager {
  UpdateManager({this.versionUrl, this.appId, this.countryCode = 'US'});

  final String? versionUrl;
  final int? appId;
  final String countryCode;

  /// Fetch update results filter by [countryCode] if [appId] is provided
  ///
  /// [countryCode] is ISO 3166-1-alpha-2 country code
  ///
  /// Example: US, EU, UK, SG, MY
  Future<UpdateResult?> fetchUpdates() async {
    if (Platform.isIOS) {
      assert(appId != null, "appId must not be null for iOS");
      return await IosAppId(appId!, countryCode).fetchUpdate();
    } else if (Platform.isAndroid || Platform.isWindows) {
      assert(versionUrl != null,
          'versionUrl must not be null for the current platform.');
      return await Url(versionUrl!).fetchUpdate();
    } else {
      throw Exception('Platform not supported');
    }
  }
}
