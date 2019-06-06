import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import '../pages/pages.dart';
import 'services.dart';

class ConnectionMethods {
  static Future<void> connectIndividually(
    BuildContext context,
    ConnectionModel model, {
    @required String address,
    String port,
    String username,
    String passwordOrKey,
    String path,
    bool setIsLoading = true,
  }) async {
    model.fileInfos = [];
    model.client = SSHClient(
      host: address,
      port: port != null && port != "" ? int.parse(port) : 22,
      username: username,
      passwordOrKey: passwordOrKey,
    );
    if (setIsLoading) {
      model.isLoading = true;
    }
    bool connected = true;
    try {
      await model.client.connect();
    } catch (e) {
      connected = false;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Unable to connect to $address\n$e"),
        ),
      );
    }
    if (connected) {
      await model.client.connectSFTP();
      bool pathIsGiven = path.length != 0;
      if (!pathIsGiven || path[0] != "/") {
        path = await model.client.execute("pwd");
        path = path.substring(0, path.length - (Platform.isIOS ? 1 : 2));
      }
      bool pathIsValid = true;
      var list;
      try {
        list = await model.client.sftpLs(path);
      } catch (e) {
        pathIsValid = false;
        ConnectionPage.scaffoldKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text("Unable to go to directory $path\n$e"),
          ),
        );
      }
      if (pathIsValid) {
        model.currentConnection = Connection(address: address, port: port, username: username, passwordOrKey: passwordOrKey, path: path);
        model.fileInfos = [];
        model.fileInfos.length = list.length;
        for (int i = 0; i < list.length; i++) {
          model.fileInfos[i] = {};
          list[i].forEach((k, v) {
            model.fileInfos[i].addAll({k.toString(): v.toString()});
          });
          model.fileInfos[i]["filename"] = _removeTrailingSlash(model.fileInfos[i]["filename"]);
          model.fileInfos[i].addAll({"convertedFileSize": ""});
        }
      }
    }
    SettingsVariables.setFilesizeUnit(SettingsVariables.filesizeUnit, model);
    model.isLoading = false;
    model.connectionsNum = model.fileInfos.length;
    model.sort();
  }

  static String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") return path.substring(0, path.length - 1);
    return path;
  }

  static Future<void> connect(BuildContext context, ConnectionModel model, Connection connection, {bool setIsLoading = true}) async {
    await connectIndividually(
      context,
      model,
      address: connection.address,
      port: connection.port,
      username: connection.username,
      passwordOrKey: connection.passwordOrKey,
      path: connection.path,
      setIsLoading: setIsLoading,
    );
  }

  static Future<void> goToDirectory(BuildContext context, ConnectionModel model, String value) async {
    await connectIndividually(
      context,
      model,
      address: model.currentConnection.address,
      port: model.currentConnection.port,
      username: model.currentConnection.username,
      passwordOrKey: model.currentConnection.passwordOrKey,
      path: value,
    );
  }

  static Future<void> goToDirectoryBefore(BuildContext context, ConnectionModel model) async {
    String current = model.currentConnection.path;
    int lastSlashIndex;
    for (int i = 0; i < current.length - 1; i++) {
      if (current[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    model.directoryBefore = current.substring(0, lastSlashIndex);
    goToDirectory(context, model, model.directoryBefore);
  }

  static Future<void> refresh(BuildContext context, ConnectionModel model) async {
    await connect(context, model, model.currentConnection);
  }
}
