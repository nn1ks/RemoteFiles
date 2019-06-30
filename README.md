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

#### SFTP connection
The [ssh package](https://pub.dev/packages/ssh) is used to connect to SFTP, which wraps iOS library [NMSSH](https://github.com/NMSSH/NMSSH) and Android library [JSch](http://www.jcraft.com/jsch/).

#### Connection data
The connections are saved in two JSON files (favorites.json & recentlyAdded.json).<br/>
On Android the files are located in the ApplicationDocumentsDirectory.<br/>
On iOS the files are located in the ApplicationSupportDirectory.

#### Downloaded files
On Android the downloaded files are saved to external storage (default: /storage/emulated/0/RemoteFiles). The location can be changed on Android in the settings.<br/>
On iOS the downloaded files are saved in the ApplicationDocumentsDirectory.

#### Get directories
The [path_provider package](https://pub.dev/packages/path_provider) is used to get the directories listed above.

#### Permissions
To save files to external storage, the `WRITE_EXTERNAL_STORAGE` permission is needed on Android. To request and check this permission the [permission_handler package](https://pub.dev/packages/permission_handler) is used.

---

## Downloads

- [APK file](https://github.com/niklas-8/RemoteFiles/releases)
- Google PlayStore (not yet available)

---

## Screenshots

<img src="screenshots/1.jpg" width="280px"> <img src="screenshots/2.jpg" width="280px"> <img src="screenshots/3.jpg" width="280px">
<img src="screenshots/4.jpg" width="280px"> <img src="screenshots/5.jpg" width="280px"> <img src="screenshots/6.jpg" width="280px">
<img src="screenshots/7.jpg" width="280px"> <img src="screenshots/8.jpg" width="280px"> <img src="screenshots/9.jpg" width="280px">