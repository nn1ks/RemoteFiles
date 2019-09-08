import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class ConnectionPage extends StatefulWidget {
  final Connection connection;
  List<FileInfo> fileInfos;
  List<FileInfo> visibleFileInfos;

  ConnectionPage(this.connection);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  sortFileInfos() {
    fileInfos.sort((a, b) {
      String n1 = a.toMap()[SettingsVariables.sort].toLowerCase();
      String n2 = b.toMap()[SettingsVariables.sort].toLowerCase();
      return n1.compareTo(n2);
    });
    if (SettingsVariables.sortIsDescending) {
      fileInfos = fileInfos.reversed.toList();
    }
    if (SettingsVariables.sort == "name") {
      fileInfos = fileInfos.reversed.toList();
    }
    visibleFileInfos = fileInfos;
  }

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  bool _isSelectionMode = false;
  List<bool> _isSelected = [];
  bool _selectedItemsAreFiles = true;

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text(
            "/",
            style: TextStyle(
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

  void _setDownloadEnable() {
    _selectedItemsAreFiles = true;
    for (int i = 0; i < widget.visibleFileInfos.length; i++) {
      if (_isSelected[i] && widget.visibleFileInfos[i].isDirectory) {
        _selectedItemsAreFiles = false;
      }
    }
  }

  List<Widget> _getItemList(
    ConnectionModel model, {
    bool addBottomSpace = false,
  }) {
    if (widget.visibleFileInfos == null) widget.visibleFileInfos = [];
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
                _setDownloadEnable();
              } else {
                if (widget.visibleFileInfos[i].isDirectory) {
                  ConnectionMethods.goToDirectory(
                    context,
                    widget.connection.path +
                        (widget.connection
                                    .path[widget.connection.path.length - 1] ==
                                "/"
                            ? ""
                            : "/") +
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
                  _setDownloadEnable();
                } else {
                  _isSelectionMode = false;
                }
              });
            },
          ));
        }
      }
    }
    list.add(Container(height: addBottomSpace ? 84 : 0));
    return list;
  }

  Widget _buildGoToDirectoryWidget() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).textTheme.body1.color.withOpacity(.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ),
          child: Text(
            'Go to directory "' + _searchController.text + '"',
            style: TextStyle(fontSize: 16),
          ),
        ),
        onTap: () {
          ConnectionMethods.goToDirectory(
            context,
            _searchController.text,
            widget.connection,
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionRow() {
    List<Widget> widgets = [];
    var model = Provider.of<ConnectionModel>(context);
    if (_isSelectionMode) {
      widgets.add(
        CustomTooltip(
          message: "Download",
          child: Opacity(
            opacity: _selectedItemsAreFiles ? 1 : .5,
            child: FloatingActionRowButton(
              icon: Icon(OMIcons.getApp),
              onTap: () async {
                if (_selectedItemsAreFiles) {
                  List<String> filenames = [];
                  for (int i = 0; i < widget.visibleFileInfos.length; i++) {
                    if (_isSelected[i]) {
                      filenames.add(widget.visibleFileInfos[i].name);
                    }
                  }
                  void download(int i) {
                    if (i >= filenames.length - 1) {
                      LoadFile.download(
                        context,
                        widget.connection.path + "/" + filenames[i],
                        widget,
                        ignoreExistingFiles: true,
                      );
                    } else {
                      LoadFile.download(
                        context,
                        widget.connection.path + "/" + filenames[i],
                        widget,
                        ignoreExistingFiles: true,
                      ).then((_) {
                        download(i + 1);
                      });
                    }
                  }

                  bool filenameExists = await LoadFile.filenameExistsIn(
                    directory: await SettingsVariables.getDownloadDirectory(),
                    filenames: filenames,
                  );

                  if (filenameExists) {
                    customShowDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog(
                            title: Text(
                              "There are already files with the same name. " +
                                  "Replace files?",
                              style: TextStyle(fontFamily: "GoogleSans"),
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
                                    color: Provider.of<CustomTheme>(context)
                                            .isLightTheme(context)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                elevation: .0,
                                onPressed: () {
                                  download(0);
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: .0),
                            ],
                          );
                        });
                  } else {
                    download(0);
                  }
                }
              },
            ),
          ),
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Delete",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.delete),
            onTap: () {
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
          ),
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Copy to",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.fileCopy),
            onTap: () {
              _isSelectionMode = false;
              model.isPasteMode = true;
              model.isCopyMode = true;
              model.savedFilePaths = [];
              model.savedFileInfos = [];
              for (int i = 0; i < widget.visibleFileInfos.length; i++) {
                if (_isSelected[i]) {
                  model.savedFilePaths.add(widget.connection.path +
                      "/" +
                      widget.visibleFileInfos[i].name);
                  model.savedFileInfos.add(widget.visibleFileInfos[i]);
                }
              }
              _isSelected = [];
              setState(() {});
            },
          ),
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Move to",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.keyboardTab),
            onTap: () {
              _isSelectionMode = false;
              model.isPasteMode = true;
              model.isCopyMode = false;
              model.savedFilePaths = [];
              model.savedFileInfos = [];
              for (int i = 0; i < widget.visibleFileInfos.length; i++) {
                if (_isSelected[i]) {
                  model.savedFilePaths.add(widget.connection.path +
                      "/" +
                      widget.visibleFileInfos[i].name);
                  model.savedFileInfos.add(widget.visibleFileInfos[i]);
                }
              }
              _isSelected = [];
              setState(() {});
            },
          ),
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Cancel",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.clear),
            onTap: () {
              setState(() {
                for (int i = 0; i < _isSelected.length; i++) {
                  _isSelected[i] = false;
                }
                _isSelectionMode = false;
              });
            },
          ),
        ),
      );
    } else if (Provider.of<ConnectionModel>(context).isPasteMode) {
      widgets.add(
        CustomTooltip(
          message: "Paste",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.saveAlt),
            onTap: () async {
              for (int i = 0; i < model.savedFileInfos.length; i++) {
                String cmd;
                if (model.isCopyMode) {
                  cmd = SettingsVariables.copyCommand;
                  if (model.savedFileInfos[i].isDirectory &&
                      SettingsVariables.copyCommandAppend) {
                    cmd += " -r";
                  }
                } else {
                  cmd = SettingsVariables.moveCommand;
                  if (model.savedFileInfos[i].isDirectory &&
                      SettingsVariables.moveCommandAppend) {
                    cmd += " -r";
                  }
                }
                String toPath = widget.connection.path + "/";
                if (model.isCopyMode) toPath += model.savedFileInfos[i].name;
                await model.client.execute(
                    cmd + " " + model.savedFilePaths[i] + " " + toPath);
              }

              model.isPasteMode = false;
              await ConnectionMethods.refresh(context, widget.connection);
            },
          ),
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Cancel",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.clear),
            onTap: () {
              setState(() {
                model.isPasteMode = false;
              });
            },
          ),
        ),
      );
    } else {
      widgets.add(
        CustomTooltip(
          message: "Create folder",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.createNewFolder),
            onTap: () async {
              customShowDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                    title: Text("Create Folder"),
                    content: TextField(
                      decoration: InputDecoration(
                        labelText: "Name",
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
                        await Provider.of<ConnectionModel>(context)
                            .client
                            .sftpMkdir(
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
        ),
      );
      widgets.add(
        FloatingActionRowDivider(),
      );
      widgets.add(
        CustomTooltip(
          message: "Upload file",
          child: FloatingActionRowButton(
            icon: Icon(OMIcons.publish),
            onTap: () async {
              await LoadFile.upload(context, widget);
            },
          ),
        ),
      );
    }

    return FloatingActionRow(
      heroTag: "fab",
      color: Theme.of(context).accentColor,
      children: widgets,
    );
  }

  var _searchController = TextEditingController();
  var _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.only(left: 12, top: 12, right: 12),
              padding: EdgeInsets.symmetric(horizontal: 4),
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1.4,
                    offset: Offset(0, .3),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomIconButton(
                        icon: Icon(_searchFocusNode.hasFocus
                            ? Icons.clear
                            : Icons.arrow_back),
                        onPressed: () {
                          if (_searchFocusNode.hasFocus) {
                            _searchController.clear();
                            widget.visibleFileInfos =
                                List.from(widget.fileInfos);
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {});
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      SizedBox(
                        width: constraints.maxWidth - 3 * 44,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            focusColor: Theme.of(context).accentColor,
                            hintText: "Search",
                          ),
                          onChanged: (String value) {
                            if (value.isEmpty) {
                              widget.visibleFileInfos =
                                  List.from(widget.fileInfos);
                            } else {
                              widget.visibleFileInfos = [];
                              widget.fileInfos.forEach((v) {
                                if (v.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                                  widget.visibleFileInfos.add(v);
                                }
                              });
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      CustomTooltip(
                        message: "Connection",
                        child: CustomIconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            ConnectionDialog(
                              context: context,
                              connection: widget.connection,
                              isConnectionPage: true,
                              primaryButtonIconData:
                                  Icons.remove_circle_outline,
                              primaryButtonLabel: "Disconnect",
                              primaryButtonOnPressed: () {
                                var model =
                                    Provider.of<ConnectionModel>(context);
                                model.client.disconnectSFTP();
                                model.client.disconnect();
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              },
                            ).show();
                          },
                        ),
                      ),
                      CustomTooltip(
                        message: "Settings",
                        child: CustomIconButton(
                          icon: Icon(OMIcons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionRow(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
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
                    : Scrollbar(
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(),
                          slivers: <Widget>[
                            SliverAppBar(
                              floating: true,
                              snap: true,
                              elevation: 2,
                              automaticallyImplyLeading: false,
                              titleSpacing: 6,
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
                                preferredSize: Size.fromHeight(
                                    _searchController.text != "" ? 42 : 1),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _searchController.text != ""
                                        ? _buildGoToDirectoryWidget()
                                        : Container(),
                                    Container(
                                      height: 1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (SettingsVariables.view == "list" ||
                                    SettingsVariables.view == "detailed"
                                ? SliverList(
                                    delegate: SliverChildListDelegate(
                                      _getItemList(model, addBottomSpace: true),
                                    ),
                                  )
                                : SliverGrid.extent(
                                    maxCrossAxisExtent: 160,
                                    children: _getItemList(model),
                                  )),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
