import 'package:flutter/foundation.dart';
import 'package:ssh/ssh.dart';
import '../pages/pages.dart';
import 'services.dart';

var connectionModel = ConnectionModel();

class ConnectionModel extends ChangeNotifier {
  SSHClient _client;
  set client(SSHClient value) {
    _client = value;
    notifyListeners();
  }

  get client => _client;

  Connection currentConnection;

  bool _isLoading = true;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  List<Map<String, String>> _fileInfos = [];
  set fileInfos(List<Map<String, String>> value) {
    _fileInfos = value;
    notifyListeners();
  }

  List<Map<String, String>> get fileInfos => _fileInfos;

  sort() {
    fileInfos.sort((a, b) => a[SettingsVariables.sort].compareTo(b[SettingsVariables.sort]));
    if (SettingsVariables.sortIsDescending) fileInfos = fileInfos.reversed.toList();
    if (SettingsVariables.sort != "filename") fileInfos = fileInfos.reversed.toList();
    notifyListeners();
  }

  int connectionsNum = HomePage.favoritesPage.connections.length > 0 ? HomePage.favoritesPage.connections.length : 1;

  String directoryBefore;

  bool showProgress = false;

  /// can be 'download', 'upload', 'cache'
  String progressType;

  /// status of the download or upload in percentage
  int progressValue = 0;

  /// name of the file that is downloading or uploading
  String loadFilename;
}
