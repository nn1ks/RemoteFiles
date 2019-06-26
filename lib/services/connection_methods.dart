import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssh/ssh.dart';
import '../pages/pages.dart';
import '../shared/shared.dart';
import 'services.dart';

class ConnectionMethods {
  static Future<bool> connectClient(
    BuildContext context, {
    @required String address,
    int port,
    String username,
    String passwordOrKey,
  }) async {
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

    if (openNewPage) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => connectionPage),
      );
    }
    bool loadingDone = false;
    Future.delayed(Duration(milliseconds: 600)).then((_) {
      if (setIsLoading && !loadingDone) model.isLoading = true;
    });

    connectionPage.fileInfos = List<Map<String, String>>();
    try {
      var list = await model.client.sftpLs(path);
      connectionPage.fileInfos.length = list.length;
      for (int i = 0; i < list.length; i++) {
        connectionPage.fileInfos[i] = {};
        list[i].forEach((k, v) {
          connectionPage.fileInfos[i].addAll({k.toString(): v.toString()});
        });
        connectionPage.fileInfos[i]["filename"] =
            _removeTrailingSlash(connectionPage.fileInfos[i]["filename"]);
        connectionPage.fileInfos[i].addAll({"convertedFileSize": ""});
      }
    } catch (e) {
      print(e);
      connectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Unable to list directory $path\n$e"),
        ),
      );
    }
    SettingsVariables.setFilesizeUnit(
      SettingsVariables.filesizeUnit,
      connectionPage,
    );
    loadingDone = true;
    model.isLoading = false;
    connectionPage.sort();
  }

  static String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static Future<void> connect(
    BuildContext context,
    Connection connection, {
    bool setIsLoading = true,
    bool openNewPage = true,
  }) async {
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

  static void goToDirectory(
    BuildContext context,
    String path,
    Connection currentConnection,
  ) {
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

  static Future<void> goToDirectoryBefore(
    BuildContext context,
    Connection currentConnection,
  ) async {
    int lastSlashIndex;
    for (int i = 0; i < currentConnection.path.length - 1; i++) {
      if (currentConnection.path[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    goToDirectory(
      context,
      currentConnection.path.substring(0, lastSlashIndex),
      currentConnection,
    );
  }

  static Future<void> refresh(
    BuildContext context,
    Connection currentConnection, {
    bool setIsLoading = true,
  }) async {
    Navigator.pop(context);
    await connect(
      context,
      currentConnection,
      setIsLoading: setIsLoading,
      openNewPage: true,
    );
  }

  static void showDeleteConfirmDialog({
    BuildContext context,
    List<String> filePaths,
    List<bool> isDirectory,
    Connection currentConnection,
    bool calledFromFileBottomSheet,
  }) {
    var model = Provider.of<ConnectionModel>(context);

    List<String> filenames = List.filled(filePaths.length, "");
    for (int i = 0; i < filePaths.length; i++) {
      for (int j = filePaths[i].length - 1; j >= 0; j--) {
        if (filePaths[i][j] != "/") {
          filenames[i] = filePaths[i][j] + filenames[i];
        } else {
          break;
        }
      }
    }

    customShowDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: Text(
            filenames.length == 1
                ? "Delete '${filenames[0]}'?"
                : "Delete ${filenames.length} files?",
            style: TextStyle(fontFamily: SettingsVariables.accentFont),
          ),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.only(
                top: 8.5,
                bottom: 8.0,
                left: 14.0,
                right: 14.0,
              ),
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              splashColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.only(
                top: 8.5,
                bottom: 8.0,
                left: 14.0,
                right: 14.0,
              ),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              elevation: .0,
              onPressed: () async {
                for (int i = 0; i < filePaths.length; i++) {
                  if (isDirectory[i]) {
                    await model.client.sftpRmdir(filePaths[i]);
                  } else {
                    await model.client.sftpRm(filePaths[i]);
                  }
                }
                Navigator.pop(context);
                if (calledFromFileBottomSheet) Navigator.pop(context);
                ConnectionMethods.refresh(context, currentConnection);
              },
            ),
            SizedBox(width: .0),
          ],
        );
      },
    );
  }
}
