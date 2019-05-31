import 'package:flutter/foundation.dart';
import 'package:ssh/ssh.dart';
import '../pages/pages.dart';
import 'services.dart';

var connectionModel = ConnectionModel();

class ConnectionModel with ChangeNotifier {
  SSHClient _client;
  set client(SSHClient value) {
    _client = value;
    notifyListeners();
  }

  SSHClient get client => _client;

  Connection currentConnection;

  bool _isLoading = true;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  int _connectionsNum = HomePage.favoritesPage.connections.length > 0 ? HomePage.favoritesPage.connections.length : 1;
  set connectionsNum(int value) {
    _connectionsNum = value;
    notifyListeners();
  }

  int get connectionsNum => _connectionsNum;

  String _directoryBefore;
  set directoryBefore(String value) {
    _directoryBefore = value;
    notifyListeners();
  }

  String get directoryBefore => _directoryBefore;

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

  bool _showProgress = false;
  set showProgress(bool value) {
    _showProgress = value;
    notifyListeners();
  }

  bool get showProgress => _showProgress;

  String _progressType;

  /// can be 'download', 'upload', 'cache'
  set progressType(String value) {
    _progressType = value;
    notifyListeners();
  }

  String get progressType => _progressType;

  int _progressValue = 0;

  /// status of the download or upload in percentage
  set progressValue(int value) {
    _progressValue = value;
    notifyListeners();
  }

  int get progressValue => _progressValue;

  String _loadFilename;

  /// name of the file that is downloading or uploading
  set loadFilename(String value) {
    _loadFilename = value;
    notifyListeners();
  }

  String get loadFilename => _loadFilename;
}
