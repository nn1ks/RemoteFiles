import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../shared/shared.dart';

class ConnectionPage extends StatefulWidget {
  final Connection connection;
  List<Map<String, String>> fileInfos;

  ConnectionPage(this.connection);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  sort() {
    try {
      fileInfos.sort((a, b) {
        a[SettingsVariables.sort].compareTo(b[SettingsVariables.sort]);
      });
      if (SettingsVariables.sortIsDescending) {
        fileInfos = fileInfos.reversed.toList();
      }
      if (SettingsVariables.sort != "filename") {
        fileInfos = fileInfos.reversed.toList();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  bool _isSelectionMode = false;
  List<bool> _isSelected = [];

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text(
            "/",
            style: TextStyle(
              fontFamily: SettingsVariables.accentFont,
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
            ),
          ),
        ),
        onTap: () {
          ConnectionMethods.goToDirectory(context, "/", widget.connection);
        },
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
    if (widget.connection != null) {
      path = widget.connection.path != null ? widget.connection.path + "/" : "";
    }
    if (path.length > 1) {
      if (path[0] == "/" && path[1] == "/") {
        path = path.substring(1, path.length);
      }
    }
    for (int i = 1; i < path.length; i++) {
      if (path[i] == "/") {
        widgets.add(InkWell(
          borderRadius: BorderRadius.circular(100.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7.0),
            child: Text(
              temp,
              style: TextStyle(
                fontFamily: SettingsVariables.accentFont,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
          onTap: () {
            ConnectionMethods.goToDirectory(
              context,
              path.substring(0, i),
              widget.connection,
            );
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

  List<Widget> _getItemList(ConnectionModel model) {
    _isSelected.length = widget.fileInfos.length;
    for (int i = 0; i < _isSelected.length; i++) {
      if (_isSelected[i] != true) {
        _isSelected[i] = false;
      }
    }
    int _connectionsNum =
        widget.fileInfos == null ? 0 : widget.fileInfos.length;
    List<Widget> list = [];
    if (widget.fileInfos.length > 0) {
      for (int i = 0; i < _connectionsNum; i++) {
        if (SettingsVariables.showHiddenFiles ||
            widget.fileInfos[i]["filename"][0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: widget.fileInfos,
            isLoading: model.isLoading,
            isSelected: _isSelected[i],
            isSelectionMode: _isSelectionMode,
            view: SettingsVariables.view,
            itemNum: _connectionsNum,
            onTap: () {
              if (_isSelectionMode) {
                setState(() {
                  _isSelected[i] = !_isSelected[i];
                  if (!_isSelected.contains(true)) {
                    _isSelectionMode = false;
                  }
                });
              } else {
                if (widget.fileInfos[i]["isDirectory"] == "true") {
                  ConnectionMethods.goToDirectory(
                    context,
                    widget.connection.path +
                        "/" +
                        widget.fileInfos[i]["filename"],
                    widget.connection,
                  );
                } else {
                  FileBottomSheet(context, widget.fileInfos[i], widget).show();
                }
              }
            },
            onSecondaryTap: () {
              FileBottomSheet(context, widget.fileInfos[i], widget).show();
            },
            onLongPress: () {
              setState(() {
                _isSelected[i] = !_isSelected[i];
                if (_isSelected.contains(true)) {
                  _isSelectionMode = true;
                } else {
                  _isSelectionMode = false;
                }
              });
            },
          ));
        }
      }
    }
    list.add(Container());
    return list;
  }

  AnimationController _rotationController;

  @override
  void initState() {
    _rotationController =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: AppBar(
          backgroundColor: Theme.of(context).bottomAppBarColor,
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
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, .08),
              blurRadius: 4.0,
              offset: Offset(.0, 2.0),
            )
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            bottomAppBarColor: _isSelectionMode
                ? Theme.of(context).accentColor
                : Theme.of(context).bottomAppBarColor,
            iconTheme: IconThemeData(
              color: _isSelectionMode
                  ? Theme.of(context).accentIconTheme.color
                  : Theme.of(context).primaryIconTheme.color,
            ),
          ),
          child: ConnectionBottomAppBar(
            context,
            currentConnectionPage: widget,
            isSelectionMode: _isSelectionMode,
            cancelSelection: () {
              setState(() {
                for (int i = 0; i < _isSelected.length; i++) {
                  _isSelected[i] = false;
                }
                _isSelectionMode = false;
              });
            },
            deleteSelectedFiles: () {
              List<String> filePaths = [];
              List<bool> isDirectory = [];
              for (int i = 0; i < widget.fileInfos.length; i++) {
                if (_isSelected[i]) {
                  filePaths.add(widget.connection.path +
                      "/" +
                      widget.fileInfos[i]["filename"]);
                  isDirectory.add(widget.fileInfos[i]["isDirectory"] == "true");
                }
              }
              ConnectionMethods.showDeleteConfirmDialog(
                context: context,
                filePaths: filePaths,
                isDirectory: isDirectory,
                currentConnection: widget.connection,
                calledFromFileBottomSheet: false,
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isSelectionMode
          ? Container()
          : Consumer<ConnectionModel>(
              builder: (context, model, child) {
                return SpeedDial(
                  overlayColor: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Color.fromRGBO(255, 255, 255, .2)
                      : Color.fromRGBO(18, 18, 18, .2),
                  heroTag: "fab",
                  child: RotationTransition(
                    turns: Tween(begin: .0, end: 0.125)
                        .animate(_rotationController),
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
                      labelStyle: TextStyle(
                        fontFamily: SettingsVariables.accentFont,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.body1.color,
                      ),
                      labelBackgroundColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.white
                              : Colors.grey[800],
                      child: Icon(OMIcons.cloudUpload),
                      backgroundColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.white
                              : Colors.grey[800],
                      foregroundColor: Theme.of(context).accentColor,
                      elevation: 3.0,
                      onTap: () async => LoadFile.upload(context, widget),
                    ),
                    SpeedDialChild(
                      label: "Create Folder",
                      labelStyle: TextStyle(
                        fontFamily: SettingsVariables.accentFont,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.body1.color,
                      ),
                      labelBackgroundColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.white
                              : Colors.grey[800],
                      child: Icon(OMIcons.createNewFolder),
                      backgroundColor:
                          Provider.of<CustomTheme>(context).isLightTheme()
                              ? Colors.white
                              : Colors.grey[800],
                      foregroundColor: Theme.of(context).accentColor,
                      elevation: 3.0,
                      onTap: () async {
                        customShowDialog(
                          context: context,
                          builder: (context) {
                            return CustomAlertDialog(
                              title: Text(
                                "Folder Name",
                                style: TextStyle(
                                  fontFamily: SettingsVariables.accentFont,
                                ),
                              ),
                              content: TextField(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                cursorColor: Theme.of(context).accentColor,
                                autofocus: true,
                                autocorrect: false,
                                onSubmitted: (String value) async {
                                  await model.client.sftpMkdir(
                                    widget.connection.path + "/" + value,
                                  );
                                  Navigator.pop(context);
                                  ConnectionMethods.refresh(
                                    context,
                                    widget.connection,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
      body: SafeArea(
        child: Scrollbar(
          child: Consumer<ConnectionModel>(
            builder: (context, model, child) {
              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: () async {
                  await ConnectionMethods.refresh(context, widget.connection);
                },
                child: model.isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SettingsVariables.view == "list" ||
                            SettingsVariables.view == "detailed"
                        ? ListView(
                            children: <Widget>[
                              Column(children: _getItemList(model)),
                              SizedBox(height: 84.0),
                            ],
                          )
                        : GridView(
                            padding: EdgeInsets.all(3.0),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 160.0,
                            ),
                            children: _getItemList(model),
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
