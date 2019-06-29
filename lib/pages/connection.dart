import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../shared/shared.dart';

class ConnectionPage extends StatefulWidget {
  final Connection connection;
  List<FileInfo> fileInfos;
  List<FileInfo> visibleFileInfos;

  ConnectionPage(this.connection);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  sortFileInfos() {
    try {
      // TODO: fix bug when calling fileInfos.sort()
      fileInfos.sort((a, b) {
        a
            .toMap()[SettingsVariables.sort]
            .compareTo(b.toMap()[SettingsVariables.sort]);
      });
    } catch (e) {
      print(e);
    }
    if (SettingsVariables.sortIsDescending) {
      fileInfos = fileInfos.reversed.toList();
    }
    if (SettingsVariables.sort != "name") {
      fileInfos = fileInfos.reversed.toList();
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
    _isSelected.length = widget.visibleFileInfos.length;
    for (int i = 0; i < _isSelected.length; i++) {
      if (_isSelected[i] != true) {
        _isSelected[i] = false;
      }
    }
    int _connectionsNum =
        widget.visibleFileInfos == null ? 0 : widget.visibleFileInfos.length;
    List<Widget> list = [];
    if (widget.visibleFileInfos.length > 0) {
      for (int i = 0; i < _connectionsNum; i++) {
        if (SettingsVariables.showHiddenFiles ||
            widget.visibleFileInfos[i].name[0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: widget.visibleFileInfos,
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
                if (widget.visibleFileInfos[i].isDirectory) {
                  ConnectionMethods.goToDirectory(
                    context,
                    widget.connection.path +
                        "/" +
                        widget.visibleFileInfos[i].name,
                    widget.connection,
                  );
                } else {
                  FileBottomSheet(context, widget.visibleFileInfos[i], widget)
                      .show();
                }
              }
            },
            onSecondaryTap: () {
              FileBottomSheet(context, widget.visibleFileInfos[i], widget)
                  .show();
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

  var _searchController = TextEditingController();
  bool _showSearch = false;

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
        preferredSize: Size.fromHeight(48),
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Visibility(
              visible: _showSearch,
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    icon: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: CustomIconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSearch = false;
                            _searchController.clear();
                            widget.visibleFileInfos =
                                List.from(widget.fileInfos);
                          });
                        },
                      ),
                    ),
                    hintText: "Search",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (String value) {
                    if (value.isEmpty) {
                      widget.visibleFileInfos = List.from(widget.fileInfos);
                    } else {
                      widget.visibleFileInfos = [];
                      widget.fileInfos.forEach((v) {
                        if (v.name.contains(value)) {
                          widget.visibleFileInfos.add(v);
                        }
                      });
                    }
                    setState(() {});
                  },
                ),
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
              for (int i = 0; i < widget.visibleFileInfos.length; i++) {
                if (_isSelected[i]) {
                  filePaths.add(widget.connection.path +
                      "/" +
                      widget.visibleFileInfos[i].name);
                  isDirectory.add(widget.visibleFileInfos[i].isDirectory);
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
            searchOnTap: () {
              setState(() {
                _showSearch = !_showSearch;
                _searchController.clear();
                widget.visibleFileInfos = List.from(widget.fileInfos);
              });
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
                      onTap: () async {
                        await LoadFile.upload(context, widget);
                      },
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).detach(),
        child: SafeArea(
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
      ),
    );
  }
}
