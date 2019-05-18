import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssh/ssh.dart';
import 'custom_tooltip.dart';
import 'custom_show_dialog.dart';
import 'connection_widget_tile.dart';
import 'favorites_page.dart';
import 'connection.dart';
import 'main.dart';

class ConnectionPage extends StatefulWidget {
  /*final String address;
  final String port;
  final String username;
  final String passwordOrKey;
  final String path;
  final Map<String, String> map;

  ConnectionPage({Key key, this.address, this.port, this.username, this.passwordOrKey, this.path, this.map}) : super(key: key);*/

  //final Connection connection;

  ConnectionPage(Connection c) {
    _ConnectionPageState._connection = c;
  }

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, String>> get fileInfos => _ConnectionPageState()._fileInfos;

  static Map<String, String> get currentConnection => _ConnectionPageState._currentConnection;
  static SSHClient get client => _ConnectionPageState._client;
  static connectMap(Map<String, String> map) => _ConnectionPageState()._connectMap(map);
  static refresh() => _ConnectionPageState()._refresh();
  static Future<bool> download(String filePath) async => await _ConnectionPageState()._download(filePath);

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> with TickerProviderStateMixin {
  static Connection _connection;

  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _showHiddenFiles = false;
  bool _isListView = true;

  static Map<String, String> _currentConnection;
  List<Map<String, String>> _fileInfos = [];
  static SSHClient _client;
  int _itemNum = FavoritesPage.favorites.length > 0 ? FavoritesPage.favorites.length : 1;
  bool _isLoading = false;
  String _directoryBefore;

  String _sortValue = "name";
  bool _fileSortDescending = true;

  _showFileBottomSheet(int index) {
    Map<String, String> fileInfo = _fileInfos[index];
    String currentPath = _currentConnection["path"];
    String filePath = currentPath;
    if (currentPath.substring(currentPath.length - 2) != "/") filePath += "/";
    filePath += _fileInfos[index]["filename"];
    double tableFontSize = 16.0;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 56.0,
                      child: ListTile(
                        leading: Icon(fileInfo["isDirectory"] == "true" ? Icons.folder_open : Icons.insert_drive_file),
                        title: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Text(
                              fileInfo["filename"],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    Container(
                      height: constraints.maxHeight - 57.0,
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Opacity(
                              opacity: .8,
                              child: Table(
                                columnWidths: {0: FixedColumnWidth(158.0)},
                                children: <TableRow>[
                                  TableRow(children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        "Permissions:",
                                        style: TextStyle(fontSize: tableFontSize),
                                      ),
                                    ),
                                    Text(
                                      fileInfo["permissions"],
                                      style: TextStyle(fontSize: tableFontSize),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        "Modification Date:",
                                        style: TextStyle(fontSize: tableFontSize),
                                      ),
                                    ),
                                    Text(
                                      fileInfo["modificationDate"],
                                      style: TextStyle(fontSize: tableFontSize),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        "Last Access:",
                                        style: TextStyle(fontSize: tableFontSize),
                                      ),
                                    ),
                                    Text(
                                      fileInfo["lastAccess"],
                                      style: TextStyle(fontSize: tableFontSize),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        "Path:",
                                        style: TextStyle(fontSize: tableFontSize),
                                      ),
                                    ),
                                    Text(
                                      currentPath + "/" + fileInfo["filename"],
                                      style: TextStyle(fontSize: tableFontSize),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 1.0,
                            margin: EdgeInsets.only(bottom: 8.0),
                            color: Theme.of(context).dividerColor,
                          ),
                          fileInfo["isDirectory"] == "true"
                              ? Container()
                              : Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.file_download, color: Theme.of(context).accentColor),
                                      title: Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Text(
                                          "Download",
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await _download(filePath);
                                      },
                                    ),
                                  ],
                                ),
                          ListTile(
                            leading: Icon(OMIcons.edit, color: Theme.of(context).accentColor),
                            title: Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Text(
                                "Rename",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            onTap: () {
                              customShowDialog(
                                context: context,
                                builder: (context) {
                                  return CustomAlertDialog(
                                    title: Text(
                                      "Rename '${fileInfo["filename"]}'",
                                      style: TextStyle(fontFamily: "GoogleSans"),
                                    ),
                                    content: TextField(
                                      decoration: InputDecoration(
                                        labelText: "New name",
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                                        ),
                                      ),
                                      cursorColor: Theme.of(context).accentColor,
                                      autofocus: true,
                                      onSubmitted: (String value) async {
                                        String newFilePath = currentPath;
                                        if (currentPath.substring(currentPath.length - 2) != "/") {
                                          newFilePath += "/";
                                        }
                                        newFilePath += value;
                                        await _client.sftpRename(
                                          oldPath: filePath,
                                          newPath: newFilePath,
                                        );
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        _refresh();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(OMIcons.delete, color: Theme.of(context).accentColor),
                            title: Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Text(
                                "Delete",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            onTap: () => _showDeleteConfirmDialog(filePath, fileInfo, index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  _showDeleteConfirmDialog(String filePath, Map<String, String> fileInfo, int index) {
    customShowDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: Text(
            "Delete '${fileInfo["filename"]}'?",
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
              onPressed: () async {
                if (_fileInfos[index]["isDirectory"] == "true") {
                  await _client.sftpRmdir(filePath);
                } else {
                  await _client.sftpRm(filePath);
                }
                Navigator.pop(context);
                Navigator.pop(context);
                _refresh();
              },
            ),
            SizedBox(width: .0),
          ],
        );
      },
    );
  }

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text("/", style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
        ),
        onTap: () => _goToDirectory("/"),
      ),
      Container(
        width: .0,
        constraints: BoxConstraints.loose(Size.fromHeight(18.0)),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              left: -9.0,
              child: Icon(
                Icons.chevron_right,
                size: 18.0,
              ),
            ),
          ],
        ),
      )
    ];
    String temp = "";
    String path = "";
    if (_currentConnection != null) path = _currentConnection["path"] != null ? _currentConnection["path"] + "/" : "";
    for (int i = 1; i < path.length; i++) {
      if (path[i] == "/") {
        widgets.add(InkWell(
          borderRadius: BorderRadius.circular(100.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7.0),
            child: Text(temp, style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
          ),
          onTap: () {
            _goToDirectory(path.substring(0, i));
          },
        ));
        if (path.substring(i + 1, path.length).contains("/")) {
          widgets.add(Container(
            width: .0,
            constraints: BoxConstraints.loose(Size.fromHeight(18.0)),
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  left: -9.0,
                  child: Icon(
                    Icons.chevron_right,
                    size: 18.0,
                  ),
                ),
              ],
            ),
          ));
        }
        temp = "";
      } else {
        temp += path[i];
      }
    }
    return widgets;
  }

  List<Widget> _getItemList() {
    List<Widget> list = [];
    if (_fileInfos.length > 0) {
      for (int i = 0; i < _itemNum; i++) {
        if (_showHiddenFiles || _fileInfos[i]["filename"][0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: _fileInfos,
            isLoading: _isLoading,
            isListView: _isListView,
            itemNum: _itemNum,
            onTap: () {
              if (_fileInfos[i]["isDirectory"] == "true") {
                setState(() {
                  _directoryBefore = _currentConnection["path"];
                });
                _goToDirectory(_currentConnection["path"] + "/" + _fileInfos[i]["filename"]);
              } else {
                //showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(_fileInfos[i], _currentConnection["path"]));
                _showFileBottomSheet(i);
              }
            },
            onLongPress: () {
              //showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(_fileInfos[i], _currentConnection["path"]));
              _showFileBottomSheet(i);
            },
          ));
        }
      }
    }
    list.addAll([Container(), Container(), Container()]);
    return list;
  }

  _connect({@required String address, String port, String username, String passwordOrKey, String path, bool setIsLoading = true}) async {
    _client = SSHClient(
      host: address,
      port: port != null && port != "" ? int.parse(port) : 22,
      username: username,
      passwordOrKey: passwordOrKey,
    );

    if (setIsLoading) {
      setState(() => _isLoading = true);
    }
    bool connected = true;
    try {
      await _client.connect();
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
      await _client.connectSFTP();
      bool pathIsGiven = path.length != 0;
      if (!pathIsGiven || path[0] != "/") {
        path = await _client.execute("pwd");
        path = path.substring(0, path.length - 2);
      }
      bool pathIsValid = true;
      var list;
      try {
        list = await _client.sftpLs(path);
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
        _currentConnection = {
          "address": address,
          "port": port != null && port != "" ? port : "22",
          "username": username != null ? username : "",
          "passwordOrKey": passwordOrKey != null ? passwordOrKey : "",
          "path": path != null ? _removeTrailingSlash(path) : "",
        };
        _fileInfos = [];
        _fileInfos.length = list.length;
        for (int i = 0; i < list.length; i++) {
          _fileInfos[i] = {};
          list[i].forEach((k, v) {
            _fileInfos[i].addAll({k.toString(): v.toString()});
          });
          _fileInfos[i]["filename"] = _removeTrailingSlash(_fileInfos[i]["filename"]);
        }
      }
    }
    setState(() {
      _isLoading = false;
      _itemNum = _fileInfos.length;
    });
    _sortItemList();
  }

  _connectMap(Map<String, String> map, {bool setIsLoading = true}) {
    _connect(
      address: map["address"],
      port: map["port"],
      username: map["username"],
      passwordOrKey: map["passwordOrKey"],
      path: map["path"],
      setIsLoading: setIsLoading,
    );
  }

  _goToDirectory(String value) {
    _connect(
      address: _currentConnection["address"],
      port: _currentConnection["port"],
      username: _currentConnection["username"],
      passwordOrKey: _currentConnection["passwordOrKey"],
      path: value,
    );
  }

  _goToDirectoryBefore() async {
    String current = _currentConnection["path"];
    int lastSlashIndex;
    for (int i = 0; i < current.length - 1; i++) {
      if (current[i] == "/") {
        lastSlashIndex = i;
      }
    }
    if (lastSlashIndex == 0) lastSlashIndex = 1;
    _directoryBefore = current.substring(0, lastSlashIndex);
    _goToDirectory(_directoryBefore);
  }

  _refresh() async {
    await _connectMap(_currentConnection);
  }

  String _removeTrailingSlash(String path) {
    if (path.length > 1 && path.substring(path.length - 1) == "/") return path.substring(0, path.length - 1);
    return path;
  }

  _sortItemList() {}

  int _progress = 0;
  double _progressHeight = .0;
  String _loadFile = "";
  bool _showDownloadProgress = false;
  bool _showUploadProgress = false;

  _download(String filePath, {bool isRedownloading = false}) async {
    await Future.delayed(Duration(milliseconds: 100));
    try {
      PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
      if (permissionStatus != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          await _saveFile(filePath, isRedownloading: isRedownloading);
        }
      } else {
        await _saveFile(filePath, isRedownloading: isRedownloading);
      }
    } catch (e) {
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text("Download failed"),
        ),
      );
    }
  }

  _saveFile(String filePath, {bool isRedownloading}) async {
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
      bool fileNameExists = false;
      var ls = await appdir.list().toList();
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
        await _client.sftpDownload(
          path: filePath,
          toPath: appdir.path,
          callback: (progress) {
            setState(() => _progress = progress);
            if (progress == 5) {
              setState(() {
                _progressHeight = 50.0;
                _loadFile = filename;
                _showDownloadProgress = true;
              });
            } else if (progress == 100) {
              _downOrUploadCompleted(true, appdir.path + "/" + filename);
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
                      _download(filePath, isRedownloading: true);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: .0),
                ],
              );
            });
      }
    } catch (e) {
      print(e);
    }
  }

  _upload({bool isReuploading = false, String pathFromReuploading}) async {
    _progress = 0;
    _showUploadProgress = true;
    String path;
    if (!isReuploading) {
      try {
        path = await FlutterDocumentPicker.openDocument();
      } catch (e) {
        print("Picking file failed");
      }
    } else {
      path = pathFromReuploading;
    }
    String filename = "";
    for (int i = 0; i < path.length; i++) {
      filename += path[i];
      if (path[i] == "/") {
        filename = "";
      }
    }
    bool fileNameExisting = false;
    var ls = await _client.sftpLs(_currentConnection["path"]);
    for (int i = 0; i < ls.length; i++) {
      if (filename == ls[i]["filename"]) fileNameExisting = true;
    }
    if (!fileNameExisting || isReuploading) {
      try {
        _client.sftpUpload(
          path: path,
          toPath: _currentConnection["path"],
          callback: (progress) {
            setState(() => _progress = progress);
            if (progress == 5) {
              setState(() {
                _progressHeight = 50.0;
                _loadFile = filename;
                _showUploadProgress = true;
              });
            } else if (progress == 100) {
              _downOrUploadCompleted(false);
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
                    _upload(isReuploading: true, pathFromReuploading: path);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: .0),
              ],
            );
          });
    }
  }

  _downOrUploadCompleted(bool isDownload, [String saveLocation]) {
    if (isDownload) {
      _progressHeight = .0;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Download completed\nSaved file to $saveLocation"),
        ),
      );
      _showDownloadProgress = false;
    } else {
      _progressHeight = .0;
      ConnectionPage.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Upload completed"),
        ),
      );
      _showUploadProgress = false;
      _connectMap(_currentConnection);
    }
  }

  set _isListViewSetter(bool value) => setState(() => _isListView = value);
  set _showHiddenFilesSetter(bool value) => setState(() => _showHiddenFiles = value);

  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    if (_currentConnection != null) _currentConnection["path"] = "";
    _connect(
      address: _connection.address,
      port: _connection.port,
      username: _connection.username,
      passwordOrKey: _connection.passwordOrKey,
      path: _connection.path,
    );
    super.initState();
  }

  int _radioGroupValue0 = 0;
  int _radioGroupValue1 = 0;
  bool _showHiddenFilesValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ConnectionPage.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: AppBar(
          elevation: 1.6,
          automaticallyImplyLeading: false,
          title: SingleChildScrollView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Row(
                children: _getCurrentPathWidgets(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, .08), blurRadius: 4.0, offset: Offset(.0, 2.0))],
        ),
        child: BottomAppBar(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: _progressHeight + 55.0,
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: _progressHeight,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 18.0, bottom: 12.0),
                              child: Text(
                                _showDownloadProgress ? "Downloading $_loadFile" : "Uploading $_loadFile",
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 12.0),
                            child: Text("$_progress%",
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          value: _progress.toDouble() * .01,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 55.0,
                  margin: EdgeInsets.only(top: _progressHeight),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      children: <Widget>[
                        CustomTooltip(
                          message: "Back",
                          child: IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        CustomTooltip(
                          message: "Show connection infos",
                          child: IconButton(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 1.0),
                              child: Icon(OMIcons.flashOn),
                            ),
                            onPressed: () {
                              MyHomePage().showConnectionDialog(
                                context: context,
                                page: "connection",
                                primaryButton: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  splashColor: Colors.black12,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                        child: Icon(
                                          Icons.remove_circle_outline,
                                          size: 19.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Disconnect",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                  padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                                  elevation: .0,
                                  onPressed: () {
                                    _client.disconnectSFTP();
                                    _client.disconnect();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                                hasSecondaryButton: false,
                              );
                            },
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: 1.0,
                          color: Theme.of(context).dividerColor,
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                        ),
                        CustomTooltip(
                          message: "Go to parent directory",
                          child: IconButton(
                            icon: RotatedBox(quarterTurns: 2, child: Icon(Icons.subdirectory_arrow_right)),
                            onPressed: () {
                              _goToDirectoryBefore();
                            },
                          ),
                        ),
                        CustomTooltip(
                          message: "Go to specific directory",
                          child: IconButton(
                            icon: Icon(Icons.youtube_searched_for),
                            onPressed: () {
                              customShowDialog(
                                context: context,
                                builder: (context) {
                                  return CustomAlertDialog(
                                    title: Text("Go to directory", style: TextStyle(fontFamily: "GoogleSans", fontSize: 18.0)),
                                    content: Container(
                                      width: 260.0,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: "Path",
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                                          ),
                                        ),
                                        cursorColor: Theme.of(context).accentColor,
                                        autofocus: true,
                                        autocorrect: false,
                                        onSubmitted: (String value) {
                                          if (value[0] == "/") {
                                            _goToDirectory(value);
                                          } else {
                                            _goToDirectory(_currentConnection["path"] + "/" + value);
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        CustomTooltip(
                          message: "View & Sort",
                          child: IconButton(
                            icon: Icon(Icons.sort),
                            onPressed: () {
                              customShowDialog(
                                context: context,
                                builder: (context) {
                                  return CustomAlertDialog(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                    content: StatefulBuilder(builder: (context, setState) {
                                      return SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 320.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                                                child: Text(
                                                  "View",
                                                  style: TextStyle(fontFamily: "GoogleSans", fontSize: 20.0, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              RadioListTile(
                                                title: Text("List"),
                                                groupValue: _radioGroupValue0,
                                                value: 0,
                                                onChanged: (int value) {
                                                  setState(() {
                                                    _radioGroupValue0 = 0;
                                                  });
                                                  _isListViewSetter = true;
                                                },
                                              ),
                                              RadioListTile(
                                                title: Text("Grid"),
                                                groupValue: _radioGroupValue0,
                                                value: 1,
                                                onChanged: (int value) {
                                                  setState(() {
                                                    _radioGroupValue0 = 1;
                                                  });
                                                  _isListViewSetter = false;
                                                },
                                              ),
                                              Container(
                                                height: 1.0,
                                                color: Theme.of(context).dividerColor,
                                                margin: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 24.0, right: 20.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Sort",
                                                      style: TextStyle(fontFamily: "GoogleSans", fontSize: 20.0, fontWeight: FontWeight.w500),
                                                    ),
                                                    Switch(
                                                      activeThumbImage: AssetImage("assets/arrow_drop_down.png"),
                                                      activeColor: Colors.grey[50],
                                                      activeTrackColor: Colors.grey[300],
                                                      inactiveThumbImage: AssetImage("assets/arrow_drop_up.png"),
                                                      inactiveTrackColor: Colors.grey[300],
                                                      inactiveThumbColor: Colors.grey[50],
                                                      value: _fileSortDescending,
                                                      onChanged: (bool value) {
                                                        setState(() => _fileSortDescending = value);
                                                        _sortItemList();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                              RadioListTile(
                                                title: Text("Name"),
                                                groupValue: _radioGroupValue1,
                                                value: 0,
                                                onChanged: (int value) {
                                                  setState(() {
                                                    _radioGroupValue1 = 0;
                                                    _sortValue = "name";
                                                  });
                                                  _sortItemList();
                                                },
                                              ),
                                              RadioListTile(
                                                title: Text("Modification Date"),
                                                groupValue: _radioGroupValue1,
                                                value: 1,
                                                onChanged: (int value) {
                                                  setState(() {
                                                    _radioGroupValue1 = 1;
                                                    _sortValue = "modificationDate";
                                                  });
                                                  _sortItemList();
                                                },
                                              ),
                                              RadioListTile(
                                                title: Text("Last Access"),
                                                groupValue: _radioGroupValue1,
                                                value: 2,
                                                onChanged: (int value) {
                                                  setState(() {
                                                    _radioGroupValue1 = 2;
                                                    _sortValue = "lastAccess";
                                                  });
                                                  _sortItemList();
                                                },
                                              ),
                                              Container(
                                                height: 1.0,
                                                color: Theme.of(context).dividerColor,
                                                margin: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
                                              ),
                                              CheckboxListTile(
                                                secondary: Padding(
                                                  padding: EdgeInsets.only(left: 10.0),
                                                  child: Icon(OMIcons.visibility),
                                                ),
                                                title: Text("Show hidden files"),
                                                value: _showHiddenFilesValue,
                                                onChanged: (bool value) {
                                                  _showHiddenFilesSetter = value;
                                                  setState(() => _showHiddenFilesValue = value);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        heroTag: "fab",
        child: RotationTransition(
          turns: Tween(begin: .0, end: 0.125).animate(_rotationController),
          child: Icon(Icons.add),
        ),
        onOpen: () {
          _rotationController.forward(from: .0);
        },
        onClose: () {
          _rotationController.animateBack(.0);
        },
        children: [
          SpeedDialChild(
            label: "Upload File",
            labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
            child: Icon(OMIcons.cloudUpload),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).accentColor,
            elevation: 3.0,
            onTap: () async => _upload(),
          ),
          SpeedDialChild(
            label: "Create Folder",
            labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500),
            child: Icon(OMIcons.createNewFolder),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).accentColor,
            elevation: 3.0,
            onTap: () async {
              customShowDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                    title: Text(
                      "Folder Name",
                      style: TextStyle(fontFamily: "GoogleSans"),
                    ),
                    content: TextField(
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                        ),
                      ),
                      cursorColor: Theme.of(context).accentColor,
                      autofocus: true,
                      autocorrect: false,
                      onSubmitted: (String value) async {
                        await _client.sftpMkdir(_currentConnection["path"] + "/" + value);
                        Navigator.pop(context);
                        _connectMap(_currentConnection);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: RefreshIndicator(
            key: _refreshKey,
            onRefresh: () async {
              await _connectMap(_currentConnection, setIsLoading: true);
            },
            child: _isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _isListView
                    ? ListView(
                        children: <Widget>[
                          Column(children: _getItemList()),
                          SizedBox(height: 84.0),
                        ],
                      )
                    : GridView(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160.0,
                        ),
                        children: _getItemList(),
                      ),
          ),
        ),
      ),
    );
  }
}
