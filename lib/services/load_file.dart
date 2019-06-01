import 'dart:io';
import 'package:RemoteFiles/services/connection_methods.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../shared/shared.dart';
import '../pages/pages.dart';
import 'services.dart';

class LoadFile {
  static Future<bool> _handlePermission() async {
    if (Platform.isIOS) {
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("This function is not yet implemented in the iOS version."),
        ),
      );
      return false;
    }
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static Future<void> download(BuildContext context, String filePath, {bool isRedownloading = false}) async {
    try {
      if (await _handlePermission()) {
        String filename = "";
        for (int i = 0; i < filePath.length; i++) {
          filename += filePath[i];
          if (filePath[i] == "/") {
            filename = "";
          }
        }
        Directory dir = await SettingsVariables.getDownloadDirectory();
        dir = await dir.create(recursive: true);
        bool fileNameExists = false;
        var ls = await dir.list().toList();
        for (int i = 0; i < ls.length; i++) {
          String lsFilenames = "";
          String path = ls[i].path;
          for (int i = 0; i < path.length; i++) {
            lsFilenames += path[i];
            if (path[i] == "/") {
              lsFilenames = "";
            }
          }
          if (filename == lsFilenames) fileNameExists = true;
        }
        if (!fileNameExists || isRedownloading) {
          await connectionModel.client.sftpDownload(
            path: filePath,
            toPath: dir.path,
            callback: (progress) {
              print(progress);
              connectionModel.progressValue = progress;
              if (progress == 5) {
                connectionModel.showProgress = true;
                connectionModel.loadFilename = filename;
                connectionModel.progressType = "download";
              } else if (progress == 100) {
                _downOrUploadCompleted(context, "download", dir.path + "/" + filename);
              }
            },
          );
        } else {
          customShowDialog(
              context: context,
              builder: (context) {
                return CustomAlertDialog(
                  title: Text(
                    "There is already a file with the same name. Replace $filename?",
                    style: TextStyle(fontFamily: "GoogleSans"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
                      child: Row(
                        children: <Widget>[
                          Text("Cancel"),
                        ],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).accentColor,
                      splashColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      elevation: .0,
                      onPressed: () {
                        download(context, filePath, isRedownloading: true);
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: .0),
                  ],
                );
              });
        }
      }
    } catch (e) {
      print(e);
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text("Download failed"),
        ),
      );
    }
  }

  static Future<void> upload(BuildContext context, {bool isReuploading = false, String pathFromReuploading}) async {
    connectionModel.progressValue = 0;
    String path;
    if (!isReuploading) {
      try {
        path = await FilePicker.getFilePath();
      } catch (e) {
        print("Picking file failed");
      }
    } else {
      path = pathFromReuploading;
    }
    if (path == null) return;
    String filename = "";
    for (int i = 0; i < path.length; i++) {
      filename += path[i];
      if (path[i] == "/") {
        filename = "";
      }
    }
    bool fileNameExisting = false;
    var ls = await connectionModel.client.sftpLs(connectionModel.currentConnection.path);
    for (int i = 0; i < ls.length; i++) {
      if (filename == ls[i]["filename"]) fileNameExisting = true;
    }
    if (!fileNameExisting || isReuploading) {
      try {
        connectionModel.client.sftpUpload(
          path: path,
          toPath: connectionModel.currentConnection.path,
          callback: (progress) {
            connectionModel.progressValue = progress;
            if (progress == 5) {
              connectionModel.showProgress = true;
              connectionModel.loadFilename = filename;
            } else if (progress == 100) {
              _downOrUploadCompleted(context, "upload");
            }
          },
        );
      } catch (e) {
        print("Uploading failed");
      }
    } else {
      customShowDialog(
          context: context,
          builder: (context) {
            return CustomAlertDialog(
              title: Text(
                "There is already a file with the same name. Replace $filename?",
                style: TextStyle(fontFamily: "GoogleSans"),
              ),
              actions: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
                  child: Row(
                    children: <Widget>[
                      Text("Cancel"),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  splashColor: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  elevation: .0,
                  onPressed: () {
                    upload(context, isReuploading: true, pathFromReuploading: path);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: .0),
              ],
            );
          });
    }
  }

  static void _downOrUploadCompleted(BuildContext context, String progressType, [String saveLocation]) {
    if (progressType == "download") {
      connectionModel.showProgress = false;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Download completed\nSaved file to $saveLocation"),
        ),
      );

      connectionModel.progressType = progressType;
    } else {
      connectionModel.showProgress = false;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Upload completed"),
        ),
      );
      ConnectionMethods.refresh(context);
    }
  }

  static Future<String> saveInCache(String filePath) async {
    Directory cacheDir = await getTemporaryDirectory();
    String filename = "";
    for (int i = 0; i < filePath.length; i++) {
      filename += filePath[i];
      if (filePath[i] == "/") {
        filename = "";
      }
    }
    await connectionModel.client.sftpDownload(
      path: filePath,
      toPath: cacheDir.path,
      callback: (progress) {
        connectionModel.progressValue = progress;
        if (progress == 5) {
          connectionModel.showProgress = true;
          connectionModel.loadFilename = filename;
          connectionModel.progressType = "cache";
        } else if (progress == 100) {
          connectionModel.showProgress = false;
        }
      },
    );
    return cacheDir.path + "/" + filename;
  }
}
