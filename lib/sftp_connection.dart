import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'connection.dart';
import 'favorites_page.dart';

class SftpConnection {
  static Map<String, String> currentConnection;
  static List<Map<String, String>> fileInfos;
  static SSHClient client;
  static bool isLoading = false;
  static int itemNum = FavoritesPage.favorites.length > 0 ? FavoritesPage.favorites.length : 1;

  static connect({@required String address, String port, String username, String passwordOrKey, String path, bool setIsLoading = true}) async {
    client = SSHClient(
      host: address,
      port: port != null && port != "" ? int.parse(port) : 22,
      username: username,
      passwordOrKey: passwordOrKey,
    );
    if (setIsLoading) {
      isLoading = true;
    }
    bool connected = true;
    try {
      await client.connect();
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
      await client.connectSFTP();
      bool pathIsGiven = path.length != 0;
      if (!pathIsGiven || path[0] != "/") {
        path = await client.execute("pwd");
        path = path.substring(0, path.length - 2);
      }
      bool pathIsValid = true;
      var list;
      try {
        list = await client.sftpLs(path);
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
        currentConnection = {
          "address": address,
          "port": port != null && port != "" ? port : "22",
          "username": username != null ? username : "",
          "passwordOrKey": passwordOrKey != null ? passwordOrKey : "",
          "path": path != null ? _removeTrailingSlash(path) : "",
        };
        fileInfos = [];
        fileInfos.length = list.length;
        for (int i = 0; i < list.length; i++) {
          fileInfos[i] = {};
          list[i].forEach((k, v) {
            fileInfos[i].addAll({k.toString(): v.toString()});
          });
          fileInfos[i]["filename"] = _removeTrailingSlash(fileInfos[i]["filename"]);
        }
      }
    }
    isLoading = false;
    itemNum = fileInfos.length;
    sortItemList();
  }

  static connectMap(Map<String, String> map, {bool setIsLoading = true}) {
    connect(
      address: map["address"],
      port: map["port"],
      username: map["username"],
      passwordOrKey: map["passwordOrKey"],
      path: map["path"],
      setIsLoading: setIsLoading,
    );
  }

  static goToDirectory(String value) {
    connect(
      address: currentConnection["address"],
      port: currentConnection["port"],
      username: currentConnection["username"],
      passwordOrKey: currentConnection["passwordOrKey"],
      path: value,
    );
  }

  static String directoryBefore;

  static goToDirectoryBefore() async {
    String current = currentConnection["path"];
    int lastSlashIndex;
    for (int i = 0; i < current.length - 1; i++) {
      if (current[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    directoryBefore = current.substring(0, lastSlashIndex);
    goToDirectory(directoryBefore);
  }

  static String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") return path.substring(0, path.length - 1);
    return path;
  }

  static String sortValue = "name";
  static bool fileSortDescending = true;

  static sortItemList() {
    if (sortValue == "name") {
      List<String> filenames = [];
      fileInfos.forEach((v) {
        filenames.add(v["filename"]);
      });
      filenames.sort();
      if (!fileSortDescending) filenames = filenames.reversed.toList();
      List<Map<String, String>> sortedFileInfos = [];
      filenames.forEach((v1) {
        fileInfos.forEach((v2) {
          if (v1 == v2["filename"]) {
            sortedFileInfos.add(v2);
          }
        });
      });
      fileInfos = sortedFileInfos;
    } else {
      List<String> list = [];
      fileInfos.forEach((v) {
        list.add(v[sortValue].replaceAll("-", "").replaceAll(" ", "").replaceAll(":", ""));
      });
      print(list);
    }
    /* else if (_sortValue == "modificationDate") {
      List<String> modificationDates = [];
      _fileInfos.forEach((v) {
        String value = v["modificationDate"].replaceAll("-", "");
        value = value.replaceAll(" ", "");
        value = value.replaceAll(":", "");
        modificationDates.add(value);
      });
      modificationDates.sort();
      if (_fileSortDescending) modificationDates = modificationDates.reversed.toList();
      for (int i = 0; i < modificationDates.length; i++) {
        modificationDates[i] =
            modificationDates[i].replaceRange(4, 4, "-").replaceRange(7, 7, "-").replaceRange(10, 10, " ").replaceRange(13, 13, ":").replaceRange(16, 16, ":");
      }
      List<Map<String, String>> sortedFileInfos = [];
      modificationDates.forEach((v1) {
        _fileInfos.forEach((v2) {
          if (v1 == v2["modificationDate"]) {
            sortedFileInfos.add(v2);
          }
        });
      });
      setState(() => _fileInfos = sortedFileInfos);
    } else if (_sortValue == "lastAccess") {
      List<String> lastAccesses = [];
      _fileInfos.forEach((v) {
        String value = v["lastAccess"].replaceAll("-", "");
        value = value.replaceAll(" ", "");
        value = value.replaceAll(":", "");
        lastAccesses.add(value);
      });
      lastAccesses.sort();
      if (_fileSortDescending) lastAccesses = lastAccesses.reversed.toList();
      for (int i = 0; i < lastAccesses.length; i++) {
        lastAccesses[i] =
            lastAccesses[i].replaceRange(4, 4, "-").replaceRange(7, 7, "-").replaceRange(10, 10, " ").replaceRange(13, 13, ":").replaceRange(16, 16, ":");
      }
      List<Map<String, String>> sortedFileInfos = [];
      lastAccesses.forEach((v1) {
        _fileInfos.forEach((v2) {
          if (v1 == v2["lastAccess"]) {
            sortedFileInfos.add(v2);
          }
        });
      });
      setState(() => _fileInfos = sortedFileInfos);
    }*/
  }
}
