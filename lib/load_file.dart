import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'dart:io';
import 'sftp_connection.dart';
import 'connection.dart';

class LoadFile {
  static int progress = 0;
  static double progressHeight = .0;
  static String loadFile = "";
  static bool showDownloadProgress = false;
  static bool showUploadProgress = false;

  static Future<bool> download(String filePath) async {
    await Future.delayed(Duration(milliseconds: 100));
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        var res = await _saveFile(filePath);
        return res != null;
      }
    } else {
      var res = await _saveFile(filePath);
      return res != null;
    }
    return false;
  }

  static Future<String> _saveFile(String filePath) async {
    String filename = "";
    for (int i = 0; i < filePath.length; i++) {
      filename += filePath[i];
      if (filePath[i] == "/") {
        filename = "";
      }
    }
    try {
      var dir = await getExternalStorageDirectory();
      var appdir = await Directory('${dir.path}/RemoteFiles').create(recursive: true);
      var filePathDownload = await SftpConnection.client.sftpDownload(
        path: filePath,
        toPath: appdir.path,
        callback: (progress) {
          progress = progress;
          if (progress == 5) {
            progressHeight = 50.0;
            loadFile = filename;
            showDownloadProgress = true;
          } else if (progress == 100) {
            _downOrUploadCompleted(true);
          }
        },
      );
      return filePathDownload;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static upload() async {
    progress = 0;
    showUploadProgress = true;
    String path;
    try {
      path = await FlutterDocumentPicker.openDocument();
    } catch (e) {
      print("Picking file failed");
    }
    String filename = "";
    for (int i = 0; i < path.length; i++) {
      filename += path[i];
      if (path[i] == "/") {
        filename = "";
      }
    }
    try {
      SftpConnection.client.sftpUpload(
        path: path,
        toPath: SftpConnection.currentConnection["path"],
        callback: (progress) {
          progress = progress;
          if (progress == 5) {
            progressHeight = 50.0;
            loadFile = filename;
            showUploadProgress = true;
          } else if (progress == 100) {
            _downOrUploadCompleted(false);
          }
        },
      );
    } catch (e) {
      print("Uploading failed");
    }
  }

  static _downOrUploadCompleted(bool isDownload) {
    if (isDownload) {
      progressHeight = .0;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Download completed"),
          action: SnackBarAction(
            label: "Show file",
            onPressed: () {},
          ),
        ),
      );
      showDownloadProgress = false;
    } else {
      progressHeight = .0;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Upload completed"),
        ),
      );
      showUploadProgress = false;
      SftpConnection.connectMap(SftpConnection.currentConnection);
    }
  }
}
