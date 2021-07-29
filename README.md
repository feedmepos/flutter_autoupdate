# flutter_updater

This library allows you to easily add auto-update functionality to your Android, iOS, and Windows Flutter application. 

Our use case was to update the app by launching the App Store on iOS or install/execute the Android APK or Windows executable; thus, this package was born. To use this package, you should adhere to the format of the Version Template below.

## Features
- Fetch updates from iTunes App Store/remote URL
- Launch App Store
- Download functionality with progress
- SHA512 hash checksum on download

## Installation

Add the following to your Android app.

- AndroidManifest.xml
```xml
<!-- Provider -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileProvider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

- android/app/src/main/res/xml/file_paths.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path path="Android/data/<package name>/" name="files_root" />
    <external-path path="." name="external_storage_root" />
</paths>
```
Update the `<package name>` to your app package name

## Examples

```dart
import 'package:flutter_updater/flutter_autoupdate.dart';

// Android/Windows
var updater = UpdateManager(versionUrl: 'versionUrl');

// iOS
var updater = UpdateManager(appId: 1500009417, countryCode: 'my');

// App Store country code, this flag is optional and only applies to iOS
var result = await updater.fetchUpdates();
print(result?.latestVersion);
print(result?.downloadUrl);
print(result?.releaseNotes);
print(result?.releaseDate);
 
if (result?.latestVersion > Version.parse('1.0.0')) {
  // Get update stream controller
  var update = await result?.initializeUpdate();
  update?.stream.listen((event) async {
    // You can build a download progressbar from the data available here
    print(event.receivedBytes);
    print(event.totalBytes);
    if (event.completed) {
      print('Download completed');

      // Close the stream controller
      await update.close();

      // On Windows, autoExit and exitDelay flag are supported.
      // On iOS, this will attempt to launch the App Store from the appId provided
      // On Android, this will simply attempt to install the downloaded APK
      await result?.runUpdate(event.path, autoExit: true, exitDelay: 5000);
    }
  });
}
```
For more information, check out the [examples](https://github.com/feedmepos/flutter_updater/tree/master/example).

## Version Template

By default, it will select the first index as the latest version. For more examples, sample.json is available for reference.

### Android
```json
[
  {
    "version": "3.0.0",
    "url": "https://storage.googleapis.com/download-dev.feedmepos.com/android/feedme-pos-3.0.0-beta.5.apk",
    "releaseNotes": "New update 3.0.0!",
    "releaseDate": "2021-07-28T11:58:25Z",
    "sha512": "2e0349c1e729eac0f4cb9f831fa1130241743c8db9e115013091dbeec6b8b86dc18c62bcbfab516033869c8ec8c8967615c622303d4bee62640c3b507051aca2"
  },
  {
    "version": "1.4.5",
    "url": "https://storage.googleapis.com/download-dev.feedmepos.com/android/feedme-pos-1.4.5.apk",
    "releaseNotes": "New update 1.4.5!",
    "releaseDate": "2021-06-16T11:58:25Z",
    "sha512": "f028475ad562f9f9566213774b02e0bd3ac2198899222687613937791307ec5d326cfb79ee2882273bffd6777f9c76371d6b2eed7d46e326fd687bc95e2edb2a"
  }
]
```

### Windows
```json
[
  {
    "version": "2.5.0",
    "url": "https://storage.googleapis.com/download-dev.feedmepos.com/feedme_sample.exe",
    "releaseNotes": "New update 2.5.0!",
    "releaseDate": "2021-07-28T11:58:25Z",
    "sha512": "53d4cc95ad07470b53b3f9bc010ab8c6776f2bc2f9f3115b0807ecebcc34175f530d02e549c260112ad08c2c86a8b92d7e7f11308df0406422be8ceea76a9190"
  }
]
```

### iOS

It supports fetching updates by app id using the official [iTunes Search API](https://itunes.apple.com/lookup?id=1500009417&country=my).


# Contributing
We welcome the community to submit pull requests.

# Bugs
- Unable to install APK automatically after enabling "Install from unknown sources" from prompt




