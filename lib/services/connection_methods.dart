import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'package:provider/provider.dart';
import '../pages/pages.dart';
import 'services.dart';

class ConnectionMethods {
  static Future<void> connectIndividually(
    BuildContext context, {
    @required String address,
    String port,
    String username,
    String passwordOrKey,
    String path,
    bool setIsLoading = true,
  }) async {
    connectionModel.client = SSHClient(
      host: address,
      port: port != null && port != "" ? int.parse(port) : 22,
      username: username,
      passwordOrKey: passwordOrKey,
    );
    if (setIsLoading) {
      connectionModel.isLoading = true;
      Provider.of<ConnectionModel>(context, listen: false).isLoading = true;
    }
    bool connected = true;
    try {
      await connectionModel.client.connect();
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
      await connectionModel.client.connectSFTP();
      bool pathIsGiven = path.length != 0;
      if (!pathIsGiven || path[0] != "/") {
        path = await connectionModel.client.execute("pwd");
        path = path.substring(0, path.length - (Platform.isIOS ? 1 : 2));
      }
      bool pathIsValid = true;
      var list;
      try {
        list = await connectionModel.client.sftpLs(path);
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
        connectionModel.currentConnection = Connection(address: address, port: port, username: username, passwordOrKey: passwordOrKey, path: path);
        connectionModel.fileInfos = [];
        connectionModel.fileInfos.length = list.length;
        for (int i = 0; i < list.length; i++) {
          connectionModel.fileInfos[i] = {};
          list[i].forEach((k, v) {
            connectionModel.fileInfos[i].addAll({k.toString(): v.toString()});
          });
          connectionModel.fileInfos[i]["filename"] = _removeTrailingSlash(connectionModel.fileInfos[i]["filename"]);
          connectionModel.fileInfos[i].addAll({"convertedFileSize": ""});
        }
      }
    }
    SettingsVariables.setFilesizeUnit(SettingsVariables.filesizeUnit);
    connectionModel.isLoading = false;
    connectionModel.connectionsNum = connectionModel.fileInfos.length;
    connectionModel.sort();
    Provider.of<ConnectionModel>(context, listen: false).isLoading = false;
  }

  static String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") return path.substring(0, path.length - 1);
    return path;
  }

  static Future<void> connect(BuildContext context, Connection connection, {bool setIsLoading = true}) async {
    await connectIndividually(
      context,
      address: connection.address,
      port: connection.port,
      username: connection.username,
      passwordOrKey: connection.passwordOrKey,
      path: connection.path,
      setIsLoading: setIsLoading,
    );
  }

  static Future<void> goToDirectory(BuildContext context, String value) async {
    await connectIndividually(
      context,
      address: connectionModel.currentConnection.address,
      port: connectionModel.currentConnection.port,
      username: connectionModel.currentConnection.username,
      passwordOrKey: connectionModel.currentConnection.passwordOrKey,
      path: value,
    );
  }

  static Future<void> goToDirectoryBefore(BuildContext context) async {
    String current = connectionModel.currentConnection.path;
    int lastSlashIndex;
    for (int i = 0; i < current.length - 1; i++) {
      if (current[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    connectionModel.directoryBefore = current.substring(0, lastSlashIndex);
    goToDirectory(context, connectionModel.directoryBefore);
  }

  static Future<void> refresh(BuildContext context) async {
    await connect(context, connectionModel.currentConnection);
  }
}
