# flutter_updater

We wanted to implement auto-update functionality for Android, iOS, and Windows using a versioning JSON file; thus, this package was born. It supports checking if an update is available, downloading the latest executable, and install the file.

# Versioning

By default, it will select the first index as the latest version. For more examples, sample.json is available for reference.

## Android
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

## Windows
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

## iOS

It supports fetching updates by app id using the official [iTunes Search API](https://itunes.apple.com/lookup?id=1500009417&country=my).

# Features
- Fetch updates from iTunes App Store/URL
- Download functionality with progress
- SHA512 hash checksum on download

# Bugs
- Unable to install APK automatically after enabling "Install from unknown sources" from prompt




