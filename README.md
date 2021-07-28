# flutter_updater

We wanted to implement auto-update functionality for Android, iOS, and Windows by using a versioning JSON file thus this package was born. It supports checking if an update is available, downloading the latest executable, and install the file. 

# Versioning JSON

By default, it will select the first index as the latest version. For more examples, sample.json is available for reference.

### Android
```json
[
  {
    "version": "3.0.0",
    "url": "https://storage.googleapis.com/download-dev.feedmepos.com/android/feedme-pos-3.0.0-beta.5.apk",
    "releaseNotes": "New update 3.0.0!",
    "releaseDate": "2021-07-28T11:58:25Z"
  },
  {
    "version": "1.4.5",
    "url": "https://storage.googleapis.com/download-dev.feedmepos.com/android/feedme-pos-1.4.5.apk",
    "releaseNotes": "New update 1.4.5!",
    "releaseDate": "2021-06-16T11:58:25Z"
  }
]
```

### iOS
It supports fetching updates by app id using the official [iTunes Search API](https://itunes.apple.com/lookup?id=1500009417&country=my).

# Example
```dart
import 'package:flutter_updater/flutter_updater.dart';

var manager = UpdateManager('1.0.0', versionUrl: 'https://storage.googleapis.com/download-dev.feedmepos.com/version_windows_sample.json');
try {
    var result = await manager.checkUpdates();
    var download = await result.initializeUpdate();
    download.stream.listen((event) async {
        if (event.completed) {
            await download.close();
            // autoExit flag only applies to Windows
            await result.runUpdate(event.path, autoExit: true, exitDelay: 3000);
        }
    });
} on Exception catch (e) {
    print(e);
}
```

