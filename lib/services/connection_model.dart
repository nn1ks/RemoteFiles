import 'package:flutter/foundation.dart';
import 'package:ssh/ssh.dart';

class ConnectionModel with ChangeNotifier {
  SSHClient _client;
  set client(SSHClient value) {
    _client = value;
    notifyListeners();
  }

  SSHClient get client => _client;

  bool _isLoading = true;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

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
