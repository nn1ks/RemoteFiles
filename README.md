<p align="center">
  <img src="assets/app_icon_bg.png" width="100px">
</p>

<h1 align="center" style="font-weight: 600">RemoteFiles</h1>

<p align="center">RemoteFiles is a SFTP client for Android and iOS and was developed with <a href="https://flutter.dev">Flutter</a>.</p>
<p align="center">
  <a href="https://niklas-8.github.io/RemoteFiles">Website</a> · 
  <a href="https://github.com/niklas-8/RemoteFiles/releases">Releases</a>
</p>

---

The [ssh package](https://pub.dev/packages/ssh) is used to connect to SFTP, which wraps iOS library [NMSSH](https://github.com/NMSSH/NMSSH) and Android library [JSch](http://www.jcraft.com/jsch/).

The connections are saved in two JSON files (favorites.json & recentlyAdded.json) in the ApplicationDocumentsDirectory. To get the ApplicationDocumentsDirectory the [path_provider package](https://pub.dev/packages/path_provider) is used.

Downloaded files are saved to external storage, which needs 'WRITE_EXTERNAL_STORAGE' permission. To request and check this permission the [permission_handler package](https://pub.dev/packages/permission_handler) is used.

## Downloads

- [APK file](https://github.com/niklas-8/RemoteFiles/releases)
- Google PlayStore (not yet available)

## Screenshots

<img src="screenshots/1.jpg" width="280px"> <img src="screenshots/2.jpg" width="280px"> <img src="screenshots/3.jpg" width="280px">
<img src="screenshots/4.jpg" width="280px"> <img src="screenshots/5.jpg" width="280px"> <img src="screenshots/6.jpg" width="280px">