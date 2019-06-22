import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssh/ssh.dart';
import '../pages/pages.dart';
import 'services.dart';

class ConnectionMethods {
  static Future<bool> connectClient(BuildContext context, {@required String address, int port, String username, String passwordOrKey}) async {
    try {
      var model = Provider.of<ConnectionModel>(context);
      model.client = SSHClient(
        host: address,
        port: port ?? 22,
        username: username,
        passwordOrKey: passwordOrKey,
      );
      await model.client.connect();
      await model.client.connectSFTP();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> connectIndividually(
    BuildContext context, {
    @required String address,
    String port,
    String username,
    String passwordOrKey,
    String path,
    bool setIsLoading = true,
    bool openNewPage = true,
    bool hasPageBefore = true,
  }) async {
    var model = Provider.of<ConnectionModel>(context);

    ConnectionPage connectionPage = ConnectionPage(
      Connection(
        address: address,
        port: port,
        username: username,
        passwordOrKey: passwordOrKey,
        path: path,
      ),
    );

    if (path.length == 0 || path[0] != "/") {
      await model.client.execute("cd");
      path = await model.client.execute("pwd");
      path = path.substring(0, path.length - (Platform.isIOS ? 1 : 2));
      connectionPage.connection.path = path;
    }

    if (openNewPage) Navigator.push(context, MaterialPageRoute(builder: (context) => connectionPage));

    connectionPage.fileInfos = List<Map<String, String>>();
    try {
      var list = await model.client.sftpLs(path);
      connectionPage.fileInfos.length = list.length;
      for (int i = 0; i < list.length; i++) {
        connectionPage.fileInfos[i] = {};
        list[i].forEach((k, v) {
          connectionPage.fileInfos[i].addAll({k.toString(): v.toString()});
        });
        connectionPage.fileInfos[i]["filename"] = _removeTrailingSlash(connectionPage.fileInfos[i]["filename"]);
        connectionPage.fileInfos[i].addAll({"convertedFileSize": ""});
      }
    } catch (e) {
      print(e);
      if (openNewPage && hasPageBefore) {
        Navigator.pop(context);
      }
      connectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Unable to list directory $path\n$e"),
        ),
      );
    }

    SettingsVariables.setFilesizeUnit(SettingsVariables.filesizeUnit, connectionPage);
    model.isLoading = false;
    connectionPage.sort();
  }

  static String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") return path.substring(0, path.length - 1);
    return path;
  }

  static Future<void> connect(BuildContext context, Connection connection, {bool setIsLoading = true, bool openNewPage = true}) async {
    await connectIndividually(
      context,
      address: connection.address,
      port: connection.port,
      username: connection.username,
      passwordOrKey: connection.passwordOrKey,
      path: connection.path,
      setIsLoading: setIsLoading,
      openNewPage: openNewPage,
    );
  }

  static void goToDirectory(BuildContext context, String path, Connection currentConnection) {
    connect(
      context,
      Connection(
        name: currentConnection.name,
        address: currentConnection.address,
        port: currentConnection.port,
        username: currentConnection.username,
        passwordOrKey: currentConnection.passwordOrKey,
        path: path[0] == "/" ? path : currentConnection.path + "/" + path,
      ),
    );
  }

  static Future<void> goToDirectoryBefore(BuildContext context, Connection currentConnection) async {
    int lastSlashIndex;
    for (int i = 0; i < currentConnection.path.length - 1; i++) {
      if (currentConnection.path[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    goToDirectory(context, currentConnection.path.substring(0, lastSlashIndex), currentConnection);
  }

  static Future<void> refresh(BuildContext context, Connection currentConnection, {bool setIsLoading}) async {
    await connect(context, currentConnection, setIsLoading: setIsLoading, openNewPage: false);
  }
}
