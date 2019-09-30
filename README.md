<p align="center">
  <img src="assets/app_icon_bg.png" width="100px">
</p>

<h1 align="center" style="font-weight: 600">RemoteFiles</h1>

<p align="center">RemoteFiles is a SFTP client for Android and iOS and was developed with <a href="https://flutter.dev">Flutter</a> in the <a href="https://dart.dev">Dart</a> Programming Language.</p>
<p align="center">
  <a href="https://niklas-8.github.io/RemoteFiles">Website</a> · 
  <a href="https://github.com/niklas-8/RemoteFiles/releases">Releases</a>
</p>

---

## Downloads

- [Google PlayStore](https://play.google.com/store/apps/details?id=com.niklas8.remotefiles)
- [APK file](https://github.com/niklas-8/RemoteFiles/releases)

## Information

#### SFTP connection
The [ssh](https://pub.dev/packages/ssh) package is used to connect to SFTP, which wraps iOS library [NMSSH](https://github.com/NMSSH/NMSSH) and Android library [JSch](http://www.jcraft.com/jsch/).

#### Connection data
The connections are saved with the [hive](https://pub.dev/packages/hive) package and are encrypted using the [EncryptedBox](https://docs.hivedb.dev/advanced/encrypted_box). The encryption key is stored using the [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) package.<br/>
On Android the data is stored in the ApplicationDocumentsDirectory.<br/>
On iOS the data is stored in the ApplicationSupportDirectory.

#### Downloaded files
On Android the downloaded files are saved to external storage. The location can be changed on Android in the settings.<br/>
On iOS the downloaded files are saved in the ApplicationDocumentsDirectory.

#### Get directories
The [path_provider](https://pub.dev/packages/path_provider) package is used to get the directories listed above.

#### Permissions
To save files to external storage, the `WRITE_EXTERNAL_STORAGE` permission is needed on Android. To request and check this permission the [permission_handler](https://pub.dev/packages/permission_handler) package is used.

#### Get latest available version
When you go to the Settings page and then click on 'About RemoteFiles' at the bottom you can check if you have the latest available version.<br/>
The releases on GitHub are received with the GitHub API and the [http](https://pub.dev/packages/http) package in the JSON format. To get the latest version the releases are compared with the `published_at` key. Then the version numbers of the latest available version and the currently used version are compared. The version number of the latest available version is determined by the `tag_name`. The version number of the currently used version is determined by the pubspec.yaml file. To get this version number the [package_info](https://pub.dev/packages/package_info) package is used.

## Screenshots

<img src="screenshots/1.jpg" width="280px"> <img src="screenshots/2.jpg" width="280px"> <img src="screenshots/3.jpg" width="280px">
<img src="screenshots/4.jpg" width="280px"> <img src="screenshots/5.jpg" width="280px"> <img src="screenshots/6.jpg" width="280px">
