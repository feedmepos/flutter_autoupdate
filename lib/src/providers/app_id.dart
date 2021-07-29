import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_autoupdate/flutter_autoupdate.dart';
import 'package:flutter_autoupdate/src/providers/provider.dart';
import 'package:version/version.dart';

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

class IosAppId extends Provider {
  IosAppId(this.appId, this.countryCode);

  final int appId;
  final String countryCode;

  @override
  Future<UpdateResult?> fetchUpdate() async {
    var res = await Dio()
        .get('https://itunes.apple.com/lookup?id=$appId&country=$countryCode');
    if (res.statusCode == 200) {
      var decoded = IosLookupResponse.fromJson(json.decode(res.data));
      if (decoded.count > 0 && decoded.results.isNotEmpty) {
        var result = decoded.results[0];
        return UpdateResult(
            latestVersion: Version.parse(result["version"]),
            downloadUrl: buildUpdateUrl(),
            releaseNotes: result["releaseNotes"],
            releaseDate: result["currentVersionReleaseDate"]);
      } else {
        throw Exception("Fail to fetch results for the app id.");
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
