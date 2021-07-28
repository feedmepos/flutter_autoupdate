import 'dart:convert';

import 'package:version/version.dart';
import 'package:dio/dio.dart';

class IosLookupResponse {
  IosLookupResponse({required this.count, required this.results});

  final int count;
  final List<dynamic> results;

  factory IosLookupResponse.fromJson(Map<String, dynamic> json) =>
      IosLookupResponse(count: json["resultCount"], results: json["results"]);

  Map<String, dynamic> toJson() => {
        "resultCount": count,
        "results": results,
      };
}

class Ios {
  Ios(this.appId);

  final int appId;

  Future<Version> getVersion() async {
    var res = await Dio().get('https://itunes.apple.com/lookup?id=$appId');
    if (res.statusCode == 200) {
      var decoded = IosLookupResponse.fromJson(json.decode(res.data));
      if (decoded.count > 0) {
        var version = Version.parse(decoded.results[0]["version"]);
        return version;
      }
    } else {
      throw Exception(
          "Fail to lookup iOS App Id. Status code: ${res.statusCode}");
    }
    return Version(0, 0, 0);
  }
}
