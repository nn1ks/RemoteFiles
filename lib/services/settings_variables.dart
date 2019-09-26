import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../pages/pages.dart';

class SettingsVariables {
  static Box box;
  static Future<Box> initHive() async {
    Directory dir = Platform.isIOS
        ? await getApplicationSupportDirectory()
        : await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    return Hive.openBox("settings");
  }

  static Directory downloadDirectory;
  static Future<Directory> getDefaultDownloadDirectory() async {
    if (Platform.isAndroid) {
      Directory dir = await getExternalStorageDirectory();
      return Directory(dir.path + "/RemoteFiles");
    } else {
      return getApplicationDocumentsDirectory();
    }
  }

  static Future<Directory> getDownloadDirectory() async {
    Directory defaultDownloadDirectory = await getDefaultDownloadDirectory();
    return Directory(box.get(
      "downloadDirectoryPath",
      defaultValue: defaultDownloadDirectory.path,
    ));
  }

  static Future<void> setDownloadDirectory(String path) async {
    downloadDirectory = Directory(path);
    await box.put("downloadDirectoryPath", path);
  }

  static Future<Directory> setDownloadDirectoryToDefault() async {
    Directory dir = await getDefaultDownloadDirectory();
    setDownloadDirectory(dir.path);
    return dir;
  }

  static String view = "list";
  static String getView() {
    return box.get("view") ?? view;
  }

  static Future<void> setView(String value) async {
    view = value;
    await box.put("view", value);
  }

  static String sort = "name";
  static String getSort() {
    return box.get("sort") ?? sort;
  }

  static Future<void> setSort(String value) async {
    sort = value;
    await box.put("sort", value);
  }

  static bool sortIsDescending = true;
  static bool getSortIsDescending() {
    return box.get("sortIsDescending") ?? sortIsDescending;
  }

  static Future<void> setSortIsDescending(bool value) async {
    sortIsDescending = value;
    await box.put("sortIsDescending", value);
  }

  static bool showHiddenFiles = true;
  static bool getShowHiddenFiles() {
    return box.get("showHiddenFiles") ?? showHiddenFiles;
  }

  static Future<void> setShowHiddenFiles(bool value) async {
    showHiddenFiles = value;
    await box.put("showHiddenFiles", value);
  }

  static String filesizeUnit = "automatic";
  static String getFilesizeUnit() {
    return box.get("filesizeUnit") ?? filesizeUnit;
  }

  /// can be 'B', 'KB', 'MB', 'GB' and 'automatic'.
  static Future<void> setFilesizeUnit(
    String value,
    ConnectionPage currentConnectionPage,
  ) async {
    filesizeUnit = value;
    await box.put("filesizeUnit", value);

    int unitDivisor;
    switch (value) {
      case "B":
        unitDivisor = 1;
        break;
      case "KB":
        unitDivisor = 1000;
        break;
      case "MB":
        unitDivisor = 1000000;
        break;
      case "GB":
        unitDivisor = 1000000000;
        break;
    }
    if (currentConnectionPage != null) {
      currentConnectionPage.fileInfos.forEach((v) {
        int convertedSize;
        String unitValue;
        if (v.size != null) {
          if (v.size.toString().length > 9) {
            convertedSize = v.size ~/ 1000000000;
            unitValue = "GB";
          } else if (v.size.toString().length > 6) {
            convertedSize = v.size ~/ 1000000;
            unitValue = "MB";
          } else if (v.size.toString().length > 3) {
            convertedSize = v.size ~/ 1000;
            unitValue = "KB";
          } else {
            convertedSize = v.size;
            unitValue = "B";
          }
          if (unitDivisor != null) {
            convertedSize = v.size ~/ unitDivisor;
            unitValue = value;
          }
          v.convertedSize = convertedSize.toString() + " $unitValue";
        }
      });
    }
  }

  static String moveCommand = "mv";
  static String getMoveCommand() {
    return box.get("moveCommand") ?? moveCommand;
  }

  static Future<void> setMoveCommand(String value) async {
    moveCommand = value;
    await box.put("moveCommand", value);
  }

  static Future<String> setMoveCommandToDefault() async {
    await setMoveCommand("mv");
    return moveCommand;
  }

  static bool moveCommandAppend = false;
  static bool getMoveCommandAppend() {
    return box.get("moveCommandAppend") ?? moveCommandAppend;
  }

  static Future<void> setMoveCommandAppend(bool value) async {
    moveCommandAppend = value;
    await box.put("moveCommandAppend", value);
  }

  static String copyCommand = "cp";
  static String getCopyCommand() {
    return box.get("copyCommand") ?? copyCommand;
  }

  static Future<void> setCopyCommand(String value) async {
    copyCommand = value;
    await box.put("copyCommand", value);
  }

  static Future<String> setCopyCommandToDefault() async {
    await setCopyCommand("cp");
    return copyCommand;
  }

  static bool copyCommandAppend = true;
  static bool getCopyCommandAppend() {
    return box.get("copyCommandAppend") ?? copyCommandAppend;
  }

  static Future<void> setCopyCommandAppend(bool value) async {
    copyCommandAppend = value;
    await box.put("copyCommandAppend", value);
  }

  static initState() {
    initHive().then((box) {
      SettingsVariables.box = box;
      getDownloadDirectory().then((Directory dir) => downloadDirectory = dir);
      view = getView();
      sort = getSort();
      sortIsDescending = getSortIsDescending();
      showHiddenFiles = getShowHiddenFiles();
      filesizeUnit = getFilesizeUnit();
      moveCommand = getMoveCommand();
      moveCommandAppend = getMoveCommandAppend();
      copyCommand = getCopyCommand();
      copyCommandAppend = getCopyCommandAppend();
    });
  }
}
