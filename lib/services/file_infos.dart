import 'services.dart';

class FileInfos {
  static List<Map<String, String>> values = [];

  static sort() {
    values.sort((a, b) => a[SettingsVariables.sort].compareTo(b[SettingsVariables.sort]));
    if (SettingsVariables.sortIsDescending) values = values.reversed.toList();
    if (SettingsVariables.sort != "filename") values = values.reversed.toList();
  }
}
