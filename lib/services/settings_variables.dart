import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/pages.dart';

class SettingsVariables {
  static SharedPreferences prefs;
  static Future<void> setSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Directory downloadDirectory;
  static Future<Directory> getDownloadDirectory() async {
    Directory dirDefault;
    if (!Platform.isIOS) {
      dirDefault = await getExternalStorageDirectory();
      dirDefault = Directory(dirDefault.path + "/RemoteFiles");
    } else {
      return getApplicationDocumentsDirectory();
    }
    Directory dirPrefs;
    if (prefs != null) {
      if (prefs.getString("downloadDirectoryPath") != null) {
        dirPrefs = Directory(prefs.getString("downloadDirectoryPath"));
      }
    }
    if (dirPrefs != null) return dirPrefs;
    return dirDefault;
  }

  static Future<void> setDownloadDirectory(String path) async {
    downloadDirectory = Directory(path);
    await prefs.setString("downloadDirectoryPath", path);
  }

  static Future<Directory> setDownloadDirectoryToDefault() async {
    if (!Platform.isIOS) {
      downloadDirectory = await getExternalStorageDirectory();
      downloadDirectory = Directory(downloadDirectory.path + "/RemoteFiles");
    }
    setDownloadDirectory(downloadDirectory.path);
    return downloadDirectory;
  }

  static String view = "list";
  static String getView() {
    String viewPrefs;
    if (prefs != null) viewPrefs = prefs.getString("view");
    if (viewPrefs != null) return viewPrefs;
    return view;
  }

  static Future<void> setView(String value) async {
    view = value;
    await prefs.setString("view", value);
  }

  static String sort = "name";
  static String getSort() {
    String sortPrefs;
    if (prefs != null) sortPrefs = prefs.getString("sort");
    if (sortPrefs != null) return sortPrefs;
    return sort;
  }

  static Future<void> setSort(String value) async {
    sort = value;
    await prefs.setString("sort", value);
  }

  static bool sortIsDescending = false;
  static bool getSortIsDescending() {
    bool sortIsDescendingPrefs;
    if (prefs != null) {
      sortIsDescendingPrefs = prefs.getBool("sortIsDescending");
    }
    if (sortIsDescendingPrefs != null) return sortIsDescendingPrefs;
    return sortIsDescending;
  }

  static Future<void> setSortIsDescending(bool value) async {
    sortIsDescending = value;
    await prefs.setBool("sortIsDescending", value);
  }

  static bool showHiddenFiles = true;
  static bool getShowHiddenFiles() {
    bool showHiddenFilesPrefs;
    if (prefs != null) showHiddenFilesPrefs = prefs.getBool("showHiddenFiles");
    if (showHiddenFilesPrefs != null) return showHiddenFilesPrefs;
    return showHiddenFiles;
  }

  static Future<void> setShowHiddenFiles(bool value) async {
    showHiddenFiles = value;
    await prefs.setBool("showHiddenFiles", value);
  }

  static String filesizeUnit = "automatic";
  static String getFilesizeUnit() {
    String filesizeUnitPrefs;
    if (prefs != null) filesizeUnitPrefs = prefs.getString("filesizeUnit");
    if (filesizeUnitPrefs != null) return filesizeUnitPrefs;
    return filesizeUnit;
  }

  /// can be 'B', 'KB', 'MB', 'GB' and 'automatic'.
  static Future<void> setFilesizeUnit(
    String value,
    ConnectionPage currentConnectionPage,
  ) async {
    filesizeUnit = value;
    await prefs.setString("filesizeUnit", value);

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

  static bool showAddressInAppBar = true;
  static bool getShowAddressInAppBar() {
    bool showAddressInAppBarPrefs;
    if (prefs != null) {
      showAddressInAppBarPrefs = prefs.getBool("showAddressInAppBar");
    }
    if (showAddressInAppBarPrefs != null) return showAddressInAppBarPrefs;
    return showAddressInAppBar;
  }

  static Future<void> setShowAddressInAppBar(bool value) async {
    showAddressInAppBar = value;
    await prefs.setBool("showAddressInAppBar", value);
  }

  static String accentFont = "default";
  static String getAccentFont() {
    String accentFontPrefs;
    if (prefs != null) accentFontPrefs = prefs.getString("accentFont");
    if (accentFontPrefs != null) return accentFontPrefs;
    return accentFont;
  }

  static Future<void> setAccentFont(String value) async {
    accentFont = value;
    await prefs.setString("accentFont", value);
  }

  static initState() {
    setSharedPreferences().then((_) {
      getDownloadDirectory().then((Directory dir) => downloadDirectory = dir);
      view = getView();
      sort = getSort();
      sortIsDescending = getSortIsDescending();
      showHiddenFiles = getShowHiddenFiles();
      filesizeUnit = getFilesizeUnit();
      showAddressInAppBar = getShowAddressInAppBar();
      accentFont = getAccentFont();
    });
  }
}
