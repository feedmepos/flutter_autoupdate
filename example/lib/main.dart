import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_updater/flutter_updater.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:version/version.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  UpdateResult? _result;
  DownloadProgress? _download;
  var _startTime = DateTime.now().millisecondsSinceEpoch;
  var _bytesPerSec = 0;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    UpdateResult result;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        await Permission.storage.request();
      }
    }

    var versionUrl;
    if (Platform.isAndroid) {
      versionUrl =
          'https://storage.googleapis.com/download-dev.feedmepos.com/version_android_sample.json';
    } else if (Platform.isWindows) {
      versionUrl =
          'https://storage.googleapis.com/download-dev.feedmepos.com/version_windows_sample.json';
    }
    /// Android/Windows
    var manager = UpdateManager(versionUrl: versionUrl);
    /// iOS
    //var manager = UpdateManager(appId: 1500009417);
    try {
      result = await manager.checkUpdates();
      setState(() {
        _result = result;
      });
      if (Version.parse('1.0.0') < result.latestVersion) {
        var controller = await result.initializeUpdate();
        controller.stream.listen((event) async {
          setState(() {
            if (DateTime.now().millisecondsSinceEpoch - _startTime >= 1000) {
              _startTime = DateTime.now().millisecondsSinceEpoch;
              _bytesPerSec = event.receivedBytes - _bytesPerSec;
            }
            _download = event;
          });
          if (event.completed) {
            print("Downloaded completed");
            await controller.close();
            await result.runUpdate(event.path, autoExit: true);
          }
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _download != null
              ? Text('Latest version: ${_result!.latestVersion}\n'
                  'Url: ${_result!.downloadUrl}\n'
                  'Release Notes: ${_result!.releaseNotes}\n'
                  'Relase Date: ${_result!.releaseDate}\n\n'
                  'File: ${_download!.toPrettyMB(_download!.receivedBytes)}/'
                  '${_download!.toPrettyMB(_download!.totalBytes)} '
                  '(${_download!.progress.toInt()}%)\n'
                  'Speed: ${_download!.toPrettyMB(_bytesPerSec)}/s\n'
                  'Destination: ${_download!.path}')
              : null,
        ),
      ),
    );
  }
}
