import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_updater/flutter_updater.dart';
import 'package:flutter_updater/src/updater.dart';
import 'package:version/version.dart';

class IosLookupResponse {
  IosLookupResponse(this.count, this.results);

  final int count;
  final List<dynamic> results;

  factory IosLookupResponse.fromJson(Map<String, dynamic> json) =>
      IosLookupResponse(json["resultCount"], json["results"]);

  Map<String, dynamic> toJson() => {
        "resultCount": count,
        "results": results,
      };
}

class IosAppId extends Updater {
  IosAppId(this.appId);

  final int appId;

  @override
  Future<UpdateResult> fetchUpdate() async {
    var res = await Dio().get('https://itunes.apple.com/lookup?id=$appId');
    if (res.statusCode == 200) {
      var decoded = IosLookupResponse.fromJson(json.decode(res.data));
      if (decoded.count > 0) {
        var version = Version.parse(decoded.results[0]["version"]);
        return UpdateResult(
            latestVersion: version, directUrl: buildUpdateUrl());
      } else {
        throw Exception(
            "Fail to fetch results for the app id. App id may be invalid.");
      }
    } else {
      throw Exception(
          "Fail to fetch lookup API. Status code: ${res.statusCode}.");
    }
  }

  @override
  String buildUpdateUrl() {
    return 'itms-apps://itunes.apple.com/app/$appId';
  }
}
