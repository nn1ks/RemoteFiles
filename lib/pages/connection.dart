import 'dart:io';

import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';
import '../shared/shared.dart';
import 'pages.dart';

class ConnectionPage extends StatefulWidget {
  final Connection connection;
  List<Map<String, String>> fileInfos;

  ConnectionPage(this.connection);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  sort() {
    print(fileInfos);
    fileInfos.sort((a, b) => a[SettingsVariables.sort].compareTo(b[SettingsVariables.sort]));
    if (SettingsVariables.sortIsDescending) fileInfos = fileInfos.reversed.toList();
    if (SettingsVariables.sort != "filename") fileInfos = fileInfos.reversed.toList();
    print(fileInfos);
  }

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> with TickerProviderStateMixin {
  var _refreshKey = GlobalKey<RefreshIndicatorState>();

  List<Widget> _getCurrentPathWidgets() {
    List<Widget> widgets = [
      InkWell(
        borderRadius: BorderRadius.circular(100.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
          child: Text("/", style: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w500, fontSize: 16.0)),
        ),
        onTap: () => ConnectionMethods.goToDirectory(context, "/", widget.connection),
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
    if (widget.connection != null) path = widget.connection.path != null ? widget.connection.path + "/" : "";
    if (path.length > 1) {
      if (path[0] == "/" && path[1] == "/") path = path.substring(1, path.length);
    }
    for (int i = 1; i < path.length; i++) {
      if (path[i] == "/") {
        widgets.add(InkWell(
          borderRadius: BorderRadius.circular(100.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7.0),
            child: Text(temp, style: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w500, fontSize: 16.0)),
          ),
          onTap: () {
            ConnectionMethods.goToDirectory(context, path.substring(0, i), widget.connection);
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
    int _connectionsNum = widget.fileInfos == null ? 0 : widget.fileInfos.length;
    List<Widget> list = [];
    if (widget.fileInfos.length > 0) {
      for (int i = 0; i < _connectionsNum; i++) {
        if (SettingsVariables.showHiddenFiles || widget.fileInfos[i]["filename"][0] != ".") {
          list.add(ConnectionWidgetTile(
            index: i,
            fileInfos: widget.fileInfos,
            isLoading: model.isLoading,
            view: SettingsVariables.view,
            itemNum: _connectionsNum,
            onTap: () {
              if (widget.fileInfos[i]["isDirectory"] == "true") {
                ConnectionMethods.goToDirectory(context, widget.connection.path + "/" + widget.fileInfos[i]["filename"], widget.connection);
              } else {
                showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(widget.fileInfos[i], widget));
              }
            },
            onSecondaryTap: () {
              showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(widget.fileInfos[i], widget));
            },
            onLongPress: () {
              showModalBottomSheet(context: context, builder: (context) => FileBottomSheet(widget.fileInfos[i], widget));
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
    _rotationController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
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
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, .08), blurRadius: 4.0, offset: Offset(.0, 2.0))],
        ),
        child: BottomAppBar(
          child: Consumer<ConnectionModel>(
            builder: (context, model, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: (model.showProgress ? 50.0 : 0) + 55.0,
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: model.showProgress ? 50.0 : 0,
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
                                    model.progressType == "download"
                                        ? "Downloading ${model.loadFilename}"
                                        : (model.progressType == "uploading" ? "Uploading ${model.loadFilename}" : "Caching ${model.loadFilename}"),
                                    style: TextStyle(
                                      fontSize: 15.8,
                                      fontWeight: FontWeight.w500,
                                      color: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[700] : Colors.grey[200],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 12.0),
                                child: Text(
                                  "${model.progressValue}%",
                                  style: TextStyle(
                                    fontSize: 15.8,
                                    fontWeight: FontWeight.w500,
                                    color: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[700] : Colors.grey[200],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3.0,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey[300],
                              value: model.progressValue.toDouble() * .01,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: 55.0,
                      margin: EdgeInsets.only(top: model.showProgress ? 50.0 : 0),
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
                              message: "Go to specific directory",
                              child: IconButton(
                                icon: Icon(Icons.youtube_searched_for),
                                onPressed: () {
                                  customShowDialog(
                                    context: context,
                                    builder: (context) {
                                      return CustomAlertDialog(
                                        title: Text("Go to directory", style: TextStyle(fontFamily: SettingsVariables.accentFont, fontSize: 18.0)),
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
                                              ConnectionMethods.goToDirectory(context, value, widget.connection);
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
                              message: SettingsVariables.showHiddenFiles ? "Dont't show hidden files" : "Show hidden files",
                              child: IconButton(
                                icon: Icon(SettingsVariables.showHiddenFiles ? OMIcons.visibilityOff : OMIcons.visibility),
                                onPressed: () async {
                                  await SettingsVariables.setShowHiddenFiles(!SettingsVariables.showHiddenFiles);
                                  setState(() {});
                                },
                              ),
                            ),
                            CustomTooltip(
                              message: "Settings",
                              child: IconButton(
                                icon: Icon(OMIcons.settings),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(currentConnectionPage: widget)));
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ConnectionDialog(
                                  context: context,
                                  currentConnectionPage: widget,
                                  page: "connection",
                                  primaryButtonIconData: Icons.remove_circle_outline,
                                  primaryButtonLabel: "Disconnect",
                                  primaryButtonOnPressed: () {
                                    if (!Platform.isIOS) model.client.disconnectSFTP();
                                    model.client.disconnect();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ).show();
                              },
                              onLongPress: () async {
                                await SettingsVariables.setShowAddressInAppBar(!SettingsVariables.showAddressInAppBar);
                                setState(() {});
                              },
                              child: ClipRect(
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Padding(
                                        padding: EdgeInsets.only(top: 1.0),
                                        child: Icon(OMIcons.flashOn),
                                      ),
                                      onPressed: () {
                                        ConnectionDialog(
                                          context: context,
                                          currentConnectionPage: widget,
                                          page: "connection",
                                          primaryButtonIconData: Icons.remove_circle_outline,
                                          primaryButtonLabel: "Disconnect",
                                          primaryButtonOnPressed: () {
                                            if (!Platform.isIOS) model.client.disconnectSFTP();
                                            model.client.disconnect();
                                            Navigator.popUntil(context, ModalRoute.withName('/'));
                                          },
                                        ).show();
                                      },
                                    ),
                                    AnimatedSize(
                                      vsync: this,
                                      duration: Duration(milliseconds: 200),
                                      child: Padding(
                                        padding: EdgeInsets.only(right: SettingsVariables.showAddressInAppBar ? 18.0 : .0),
                                        child: SizedBox(
                                          width: !SettingsVariables.showAddressInAppBar ? .0 : null,
                                          child: Text(
                                            widget.connection.address,
                                            style: TextStyle(fontFamily: SettingsVariables.accentFont, fontSize: 16.0, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Consumer<ConnectionModel>(builder: (context, model, child) {
        return SpeedDial(
          overlayColor: Provider.of<CustomTheme>(context).isLightTheme() ? Color.fromRGBO(255, 255, 255, .2) : Color.fromRGBO(18, 18, 18, .2),
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
              labelStyle: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.body1.color),
              labelBackgroundColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.grey[800],
              child: Icon(OMIcons.cloudUpload),
              backgroundColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.grey[800],
              foregroundColor: Theme.of(context).accentColor,
              elevation: 3.0,
              onTap: () async => LoadFile.upload(context, widget),
            ),
            SpeedDialChild(
              label: "Create Folder",
              labelStyle: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.body1.color),
              labelBackgroundColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.grey[800],
              child: Icon(OMIcons.createNewFolder),
              backgroundColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.grey[800],
              foregroundColor: Theme.of(context).accentColor,
              elevation: 3.0,
              onTap: () async {
                customShowDialog(
                  context: context,
                  builder: (context) {
                    return CustomAlertDialog(
                      title: Text(
                        "Folder Name",
                        style: TextStyle(fontFamily: SettingsVariables.accentFont),
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
                          await model.client.sftpMkdir(widget.connection.path + "/" + value);
                          Navigator.pop(context);
                          ConnectionMethods.refresh(context, widget.connection);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      }),
      body: SafeArea(
        child: Scrollbar(
          child: Consumer<ConnectionModel>(
            builder: (context, model, child) {
              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: () async {
                  await ConnectionMethods.refresh(context, widget.connection, setIsLoading: false);
                },
                child: model.isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SettingsVariables.view == "list" || SettingsVariables.view == "detailed"
                        ? ListView(
                            children: <Widget>[
                              Column(children: _getItemList(model)),
                              SizedBox(height: 84.0),
                            ],
                          )
                        : GridView(
                            padding: EdgeInsets.all(3.0),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
