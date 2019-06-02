import 'dart:io';
import 'package:RemoteFiles/services/connection_methods.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/shared.dart';
import '../pages/pages.dart';
import 'services.dart';

class LoadFile {
  static Future<bool> _handlePermission() async {
    if (Platform.isIOS) return true;
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  static Future<void> download(BuildContext context, ConnectionModel model, String filePath, {bool isRedownloading = false}) async {
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
          await model.client.sftpDownload(
            path: filePath,
            toPath: dir.path,
            callback: (progress) {
              print(progress);
              model.progressValue = progress;
              if (progress != 100) {
                model.showProgress = true;
                model.loadFilename = filename;
                model.progressType = "download";
              } else if (progress == 100) {
                _downOrUploadCompleted(context, model, "download", dir.path + "/" + filename);
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
                      padding: EdgeInsets.only(top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).accentColor,
                      splashColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      padding: EdgeInsets.only(top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                      child: Text("OK", style: TextStyle(color: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.black)),
                      elevation: .0,
                      onPressed: () {
                        download(context, model, filePath, isRedownloading: true);
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

  static Future<void> upload(BuildContext context, ConnectionModel model, {bool isReuploading = false, String pathFromReuploading}) async {
    model.progressValue = 0;
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
    var ls = await model.client.sftpLs(model.currentConnection.path);
    for (int i = 0; i < ls.length; i++) {
      if (filename == ls[i]["filename"]) fileNameExisting = true;
    }
    if (!fileNameExisting || isReuploading) {
      try {
        model.client.sftpUpload(
          path: path,
          toPath: model.currentConnection.path,
          callback: (progress) {
            model.progressValue = progress;
            if (progress != 100) {
              model.showProgress = true;
              model.loadFilename = filename;
            } else if (progress == 100) {
              _downOrUploadCompleted(context, model, "upload");
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
                    upload(context, model, isReuploading: true, pathFromReuploading: path);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: .0),
              ],
            );
          });
    }
  }

  static void _downOrUploadCompleted(BuildContext context, ConnectionModel model, String progressType, [String saveLocation]) {
    if (progressType == "download") {
      model.showProgress = false;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 6),
          content: Text("Download completed" + (Platform.isIOS ? "" : "\nSaved file to $saveLocation")),
          action: SnackBarAction(
            label: "Show file",
            textColor: Colors.white,
            onPressed: () async {
              if (Platform.isIOS) {
                await launch("shareddocuments://$saveLocation");
              } else {
                OpenFile.open(saveLocation);
              }
            },
          ),
        ),
      );
      model.progressType = progressType;
    } else {
      model.showProgress = false;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Upload completed"),
        ),
      );
      ConnectionMethods.refresh(context, model);
    }
  }

  static Future<String> saveInCache(String filePath, ConnectionModel model) async {
    Directory cacheDir = await getTemporaryDirectory();
    await cacheDir.list().forEach((v) async {
      await v.delete();
    });
    String filename = "";
    for (int i = 0; i < filePath.length; i++) {
      filename += filePath[i];
      if (filePath[i] == "/") {
        filename = "";
      }
    }
    await model.client.sftpDownload(
      path: filePath,
      toPath: cacheDir.path,
      callback: (progress) {
        model.progressValue = progress;
        if (progress != 100) {
          model.showProgress = true;
          model.loadFilename = filename;
          model.progressType = "cache";
        } else if (progress == 100) {
          model.showProgress = false;
        }
      },
    );
    return cacheDir.path + "/" + filename;
  }
}
