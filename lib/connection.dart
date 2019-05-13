import 'package:RemoteFiles/sftp_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'custom_tooltip.dart';
import 'custom_show_dialog.dart';
import 'file_bottom_sheet.dart';
import 'connection_widget_tile.dart';
import 'load_file.dart';
import 'main.dart';

class ConnectionPage extends StatefulWidget {
  final String address;
  final String port;
  final String username;
  final String passwordOrKey;
  final String path;
  final Map<String, String> map;

  ConnectionPage({Key key, this.address, this.port, this.username, this.passwordOrKey, this.path, this.map}) : super(key: key);

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _showHiddenFiles = false;
  bool _isListView = true;

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text("/", style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
        ),
        onTap: () => SftpConnection.goToDirectory("/"),
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
    if (SftpConnection.currentConnection != null) path = SftpConnection.currentConnection["path"] != null ? SftpConnection.currentConnection["path"] + "/" : "";
    for (int i = 1; i < path.length; i++) {
      if (path[i] == "/") {
        widgets.add(InkWell(
          borderRadius: BorderRadius.circular(100.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7.0),
            child: Text(temp, style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w500, fontSize: 16.0)),
          ),
          onTap: () {
            SftpConnection.goToDirectory(path.substring(0, i));
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
    if (SftpConnection.fileInfos.length > 0) {
      for (int i = 0; i < SftpConnection.itemNum; i++) {
        if (_showHiddenFiles || SftpConnection.fileInfos[i]["filename"][0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: SftpConnection.fileInfos,
            isLoading: SftpConnection.isLoading,
            isListView: _isListView,
            itemNum: SftpConnection.itemNum,
            onTap: () {
              if (SftpConnection.fileInfos[i]["isDirectory"] == "true") {
                setState(() {
                  SftpConnection.directoryBefore = SftpConnection.currentConnection["path"];
                });
                SftpConnection.goToDirectory(SftpConnection.currentConnection["path"] + "/" + SftpConnection.fileInfos[i]["filename"]);
              } else {
                FileBottomSheet(i);
              }
            },
            onLongPress: () {
              FileBottomSheet(i);
            },
          ));
        }
      }
    }
    list.addAll([Container(), Container(), Container()]);
    return list;
  }

  _setIsListView(bool value) {
    setState(() {
      _isListView = value;
    });
  }

  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    if (SftpConnection.currentConnection != null) SftpConnection.currentConnection["path"] = "";
    SftpConnection.connect(
      address: widget.address,
      port: widget.port,
      username: widget.username,
      passwordOrKey: widget.passwordOrKey,
      path: widget.path,
    );
    super.initState();
  }

  int _radioGroupValue0 = 0;
  int _radioGroupValue1 = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ConnectionPage.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight((LoadFile.showDownloadProgress || LoadFile.showUploadProgress ? 44.0 : .0) + 48.0),
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
            height: LoadFile.progressHeight + 55.0,
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: LoadFile.progressHeight,
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
                                LoadFile.showDownloadProgress ? "Downloading ${LoadFile.loadFile}" : "Uploading ${LoadFile.loadFile}",
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 12.0),
                            child: Text("${LoadFile.progress}%",
                                style: TextStyle(fontSize: 15.8, fontWeight: FontWeight.w500, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          value: LoadFile.progress.toDouble() * .01,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 55.0,
                  margin: EdgeInsets.only(top: LoadFile.progressHeight),
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
                                    SftpConnection.client.disconnectSFTP();
                                    SftpConnection.client.disconnect();
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
                              SftpConnection.goToDirectoryBefore();
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
                                            SftpConnection.goToDirectory(value);
                                          } else {
                                            SftpConnection.goToDirectory(SftpConnection.currentConnection["path"] + "/" + value);
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
                          message: _showHiddenFiles ? "Don't show hidden files" : "Show hidden files",
                          child: IconButton(
                            icon: Icon(_showHiddenFiles ? OMIcons.visibilityOff : OMIcons.visibility),
                            onPressed: () {
                              setState(() {
                                _showHiddenFiles = !_showHiddenFiles;
                              });
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
                                                _setIsListView(true);
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
                                                _setIsListView(false);
                                              },
                                            ),
                                            Container(
                                              height: 1.0,
                                              width: MediaQuery.of(context).size.width,
                                              color: Theme.of(context).dividerColor,
                                              margin: EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 24.0, right: 20.0),
                                              child: Row(
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
                                                    value: SftpConnection.fileSortDescending,
                                                    onChanged: (bool value) {
                                                      setState(() => SftpConnection.fileSortDescending = value);
                                                      SftpConnection.sortItemList();
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
                                                  SftpConnection.sortValue = "name";
                                                });
                                                SftpConnection.sortItemList();
                                              },
                                            ),
                                            RadioListTile(
                                              title: Text("Modification Date"),
                                              groupValue: _radioGroupValue1,
                                              value: 1,
                                              onChanged: (int value) {
                                                setState(() {
                                                  _radioGroupValue1 = 1;
                                                  SftpConnection.sortValue = "modificationDate";
                                                });
                                                SftpConnection.sortItemList();
                                              },
                                            ),
                                            RadioListTile(
                                              title: Text("Last Access"),
                                              groupValue: _radioGroupValue1,
                                              value: 2,
                                              onChanged: (int value) {
                                                setState(() {
                                                  _radioGroupValue1 = 2;
                                                  SftpConnection.sortValue = "lastAccess";
                                                });
                                                SftpConnection.sortItemList();
                                              },
                                            ),
                                          ],
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
            onTap: () async => LoadFile.upload(),
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
                        await SftpConnection.client.sftpMkdir(SftpConnection.currentConnection["path"] + "/" + value);
                        Navigator.pop(context);
                        SftpConnection.connectMap(SftpConnection.currentConnection);
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
              await SftpConnection.connectMap(SftpConnection.currentConnection, setIsLoading: true);
            },
            child: SftpConnection.isLoading
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
