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

  get isLoading => _isLoading;

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
