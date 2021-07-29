import 'package:dio/dio.dart';
import 'package:flutter_updater/flutter_updater.dart';
import 'package:flutter_updater/src/updater.dart';
import 'package:version/version.dart';

class Url extends Provider {
  Url(this.versionUrl);

  final String versionUrl;

  @override
  Future<UpdateResult> fetchUpdate() async {
    var res = await Dio().get(versionUrl);
    if (res.data is List) {
      var list = res.data.map((item) => UpdateResult.fromJson(item)).toList();
      return UpdateResult(
          latestVersion: list[0].latestVersion,
          downloadUrl: list[0].downloadUrl,
          releaseNotes: list[0].releaseNotes,
          releaseDate: list[0].releaseDate,
          sha512: list[0].sha512);
    } else {
      var result = UpdateResult.fromJson(res.data);
      return UpdateResult(
          latestVersion: result.latestVersion,
          downloadUrl: result.downloadUrl,
          releaseNotes: result.releaseNotes,
          releaseDate: result.releaseDate,
          sha512: result.sha512);
    }
  }

  @override
  String buildUpdateUrl() {
    throw UnimplementedError();
  }
}
