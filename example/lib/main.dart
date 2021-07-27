import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_updater/flutter_updater.dart';
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
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var result;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    var version = Version.parse('1.0.0');
    var manager = UpdateManager(version, iosAppId: '1166499145');
    result = await manager.checkUpdates();
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Update available: ${_result?.isUpdateAvailable}\n'),
        ),
      ),
    );
  }
}
