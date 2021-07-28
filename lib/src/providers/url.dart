import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_updater/flutter_updater.dart';
import 'package:flutter_updater/src/updater.dart';
import 'package:version/version.dart';

class UrlResult {
  UrlResult(this.version, this.url);

  final Version version;
  final String url;

  factory UrlResult.fromJson(Map<String, dynamic> json) =>
      UrlResult(Version.parse(json["version"]), json["url"]);

  Map<String, dynamic> toJson() => {
        "version": version.toString(),
        "url": url,
      };
}

class Url extends Updater {
  Url(this.versionUrl);

  final String versionUrl;

  @override
  Future<UpdateResult> fetchUpdate() async {
    var res = await Dio().get(versionUrl);
    var decoded = json.decode(res.data);
    if (decoded is List) {
      var list = decoded.map((item) => UrlResult.fromJson(item)).toList();
      return UpdateResult(
          latestVersion: list[0].version, directUrl: list[0].url);
    } else {
      var result = UrlResult.fromJson(decoded);
      return UpdateResult(latestVersion: result.version, directUrl: result.url);
    }
  }

  @override
  String buildUpdateUrl() {
    throw UnimplementedError();
  }
}
