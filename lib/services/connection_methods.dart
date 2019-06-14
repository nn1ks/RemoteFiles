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
  }) async {
    var model = Provider.of<ConnectionModel>(context);

    ConnectionPage currentTemp = ConnectionPage(
      Connection(
        address: address,
        port: port,
        username: username,
        passwordOrKey: passwordOrKey,
        path: path,
      ),
    );

    if (setIsLoading) model.isLoading = true;

    if (path.length == 0 || path[0] != "/") {
      await model.client.execute("cd");
      path = await model.client.execute("pwd");
      path = path.substring(0, path.length - (Platform.isIOS ? 1 : 2));
      currentTemp.connection.path = path;
    }

    if (openNewPage) Navigator.push(context, MaterialPageRoute(builder: (context) => currentTemp));

    var fileInfos = List<Map<String, String>>();
    try {
      var list = await model.client.sftpLs(path);
      fileInfos.length = list.length;
      for (int i = 0; i < list.length; i++) {
        fileInfos[i] = {};
        list[i].forEach((k, v) {
          fileInfos[i].addAll({k.toString(): v.toString()});
        });
        fileInfos[i]["filename"] = _removeTrailingSlash(fileInfos[i]["filename"]);
        fileInfos[i].addAll({"convertedFileSize": ""});
      }
      model.current = currentTemp;
      model.current.fileInfos = fileInfos;
    } catch (e) {
      print(e);
      if (openNewPage && model.current != null) {
        Navigator.pop(context);
      } else {
        model.current = currentTemp;
      }
      print("show SnackBar");
      print(model.current.connection.path);
      model.current.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Unable to list directory $path\n$e"),
        ),
      );
    }

    SettingsVariables.setFilesizeUnit(SettingsVariables.filesizeUnit, model);
    model.isLoading = false;
    model.sort();
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

  static void goToDirectory(BuildContext context, String path) {
    var currentConnection = Provider.of<ConnectionModel>(context).current.connection;
    print(path[0] == "/" ? path : currentConnection.path + "/" + path);
    print(currentConnection.path + "/" + path);
    print(path);
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

  static Future<void> goToDirectoryBefore(BuildContext context) async {
    String currentPath = Provider.of<ConnectionModel>(context).current.connection.path;
    int lastSlashIndex;
    for (int i = 0; i < currentPath.length - 1; i++) {
      if (currentPath[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    goToDirectory(context, currentPath.substring(0, lastSlashIndex));
  }

  static Future<void> refresh(BuildContext context, {bool setIsLoading}) async {
    await connect(context, Provider.of<ConnectionModel>(context).current.connection, setIsLoading: setIsLoading, openNewPage: false);
  }
}
