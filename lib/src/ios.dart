import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

class LookupResponse {
  LookupResponse({required this.resultCount, required this.results});

  final int resultCount;
  final List<dynamic> results;

  factory LookupResponse.fromJson(Map<String, dynamic> json) => LookupResponse(
      resultCount: json["resultCount"], results: json["results"]);

  Map<String, dynamic> toJson() => {
        "resultCount": resultCount,
        "results": results,
      };
}

class Ios {
  Ios(this.appId);

  final String appId;

  Future<Version?> getVersion() async {
    var url = Uri.parse('https://itunes.apple.com/lookup?id=$appId');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var decoded = LookupResponse.fromJson(json.decode(res.body));
      if (decoded.resultCount > 0) {
        var version = Version.parse(decoded.results[0]["version"]);
        return version;
      }
    }
    return null;
  }
}
