<p align="center">
  <img src="assets/app_icon_bg.png" width="100px">
</p>

<h1 align="center" style="font-weight: 600">RemoteFiles</h1>

<p align="center">An open source SFTP client for Android and iOS.</p>
<p align="center">
  <a href="https://niklas-8.github.io/RemoteFiles">Website</a> · 
  <a href="https://github.com/niklas-8/RemoteFiles/releases">Releases</a>
</p>

---

## Downloads

- [Google PlayStore](https://play.google.com/store/apps/details?id=com.niklas8.remotefiles)
- [APK file](https://github.com/niklas-8/RemoteFiles/releases)

## About

RemoteFiles is an open source SFTP client for Android and iOS with a beautiful design. It was developed with [Flutter](https://flutter.dev) in the [Dart](https://dart.dev) Programming Language.

## Features

### File Management Features

- Down- and upload files
- Delete files/folders
- Rename files/folders
- Copy and move files and folders to other locations on the server
- Share files
- Open files without permanently saving them on your device
- Create folders
- Search for files in the current directory
- Get informations like size, permissions and modification date

### Connection Features

- Securely save your connections
- Connect to a server quickly with the Quick Connect feature
- Give your connections a name so you can better organise them
- Use the favorites page to see your favorite connections or see your history of added connections on the recently added page
- Edit and delete existing connections

### Customisation

- Choose between light, dark and black theme
- Use list, detailed or grid view to view your files
- Set how your files will be sorted
- Choose whether to show dotfiles
- Set location for downloaded files
- Set shell commands for copying/moving files and folders

## Used packages

- [ssh](https://pub.dev/packages/ssh)
  - Connect to SFTP server ([`connect`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/connect.html), [`connectSFTP`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/connectSFTP.html))
  - Down- and Upload files ([`sftpDownload`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpDownload.html), [`sftpUpload`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpUpload.html))
  - Delete files/folders ([`sftpRm`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpRm.html), [`sftpRmdir`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpRmdir.html))
  - Rename files/folders ([`sftpRename`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpRename.html))
  - Move and copy files/folders ([`execute`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/execute.html)): The shell commands that are executed can be set in the settings page of the app. The default commands are `mv` and `cp`/`cp -r`.
  - Create folders ([`sftpMkdir`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpMkdir.html))
  - Get informations like size, permissions and modification date ([`sftpLs`](https://pub.dev/documentation/ssh/latest/ssh/SSHClient/sftpLs.html))

- [hive](https://pub.dev/packages/hive)
  - Store settings data (view, sort, theme, etc.) with a regular [Box](https://docs.hivedb.dev/boxes/boxes).
  - Store connection info (name, address, port, username, password, path) with [EncryptedBox](https://docs.hivedb.dev/advanced/encrypted_box).

- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
  - Securely store the 256-bit encryption key for the EncryptedBox mentioned above.

- [permission_handler](https://pub.dev/packages/permission_handler)
  - Ask for `WRITE_EXTERNAL_STORAGE` permission on Android to be able to download files.

- [file_picker](https://pub.dev/packages/file_picker)
  - Select files on your device that will be uploaded.

- [http](https://pub.dev/packages/http)
  - Get the `tag_name` of the latest release on GitHub.

- [package_info](https://pub.dev/packages/package_info)
  - Get the version name of the app version that is currently used and then compare it with the `tag_name` of the latest release on GitHub to check if you are on the latest version.

- [path_provider](https://pub.dev/packages/path_provider)
  - Get directory to store connection infos
  - Get directory to save downloaded files

- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
  - Generate app icons for Android and iOS

- [open_file](https://pub.dev/packages/open_file)
  - Open files

- [share_extend](https://pub.dev/packages/share_extend)
  - Share files

- [provider](https://pub.dev/packages/provider)
  - Used for state management

- [shared_preferences](https://pub.dev/packages/shared_preferences)

- [url_launcher](https://pub.dev/packages/url_launcher)

- [floating_action_row](https://pub.dev/packages/floating_action_row)

- [material_design_icons_flutter](https://pub.dev/packages/material_design_icons_flutter)

- [outline_material_icons](https://pub.dev/packages/outline_material_icons)

- [md2_tab_indicator](https://pub.dev/packages/md2_tab_indicator)

## Screenshots

<img src="screenshots/1.jpg" width="280px"> <img src="screenshots/2.jpg" width="280px"> <img src="screenshots/3.jpg" width="280px">
<img src="screenshots/4.jpg" width="280px"> <img src="screenshots/5.jpg" width="280px"> <img src="screenshots/6.jpg" width="280px">
