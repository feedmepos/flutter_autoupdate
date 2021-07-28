import 'package:dio/dio.dart';
import 'package:flutter_updater/flutter_updater.dart';
import 'package:flutter_updater/src/updater.dart';
import 'package:version/version.dart';

class UrlResult {
  UrlResult(
      {required this.version,
      required this.downloadUrl,
      required this.releaseNotes,
      required this.releaseDate});

  final Version version;
  final String downloadUrl;
  final String releaseNotes;
  final String releaseDate;

  factory UrlResult.fromJson(Map<String, dynamic> json) => UrlResult(
      version: Version.parse(json["version"]),
      downloadUrl: json["url"],
      releaseNotes: json["releaseNotes"],
      releaseDate: json["releaseDate"]);

  Map<String, dynamic> toJson() => {
        "version": version.toString(),
        "downloadUrl": downloadUrl,
        "releaseNotes": releaseNotes,
        "releaseDate": releaseDate
      };
}

class Url extends Provider {
  Url(this.versionUrl);

  final String versionUrl;

  @override
  Future<UpdateResult> fetchUpdate() async {
    var res = await Dio().get(versionUrl);
    if (res.data is List) {
      var list = res.data.map((item) => UrlResult.fromJson(item)).toList();
      return UpdateResult(
          latestVersion: list[0].version,
          downloadUrl: list[0].downloadUrl,
          releaseNotes: list[0].releaseNotes,
          releaseDate: list[0].releaseDate);
    } else {
      var result = UrlResult.fromJson(res.data);
      return UpdateResult(
          latestVersion: result.version,
          downloadUrl: result.downloadUrl,
          releaseNotes: result.releaseNotes,
          releaseDate: result.releaseDate);
    }
  }

  @override
  String buildUpdateUrl() {
    throw UnimplementedError();
  }
}
