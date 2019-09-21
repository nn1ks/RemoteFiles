import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class TabViewPage extends StatefulWidget {
  final String boxName;
  final bool isFavorites;

  TabViewPage(this.boxName, this.isFavorites);

  Box box;
  List<Connection> connections = [];

  void init(Box box) {
    this.box = box;
    List<dynamic> connectionsTemp = box.get(boxName);
    if (connectionsTemp != null) {
      connections = connectionsTemp.cast<Connection>();
    }
  }

  void insertConnection(int index, Connection connection) {
    connections.insert(index, connection);
    box.put(boxName, connections);
  }

  void replaceConnectionAt(int index, Connection connection) {
    connections.insert(index, connection);
    connections.removeAt(index + 1);
    box.put(boxName, connections);
  }

  void removeConnectionAt(int index) {
    connections.removeAt(index);
    box.put(boxName, connections);
  }

  void removeAllConnections() {
    connections.clear();
    box.put(boxName, connections);
  }

  @override
  _TabViewPageState createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage> {
  String _getSubtitle(int index) {
    String _output = "";
    bool _addressIsInOutput = false;
    if (index < widget.connections.length) {
      if (widget.connections[index].name != null) {
        _output += "Address: " + widget.connections[index].address;
        _addressIsInOutput = true;
      }
      if (widget.connections[index].port != "") {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: " + widget.connections[index].port;
      } else {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: 22";
      }
      if (widget.connections[index].username != "") {
        _output += ", Username: " + widget.connections[index].username;
      }
      if (widget.connections[index].path != "") {
        _output += ", Path: " + widget.connections[index].path;
      }
    }
    return _output;
  }

  List<GlobalKey> _reorderableKeys;

  void _addKeys() {
    setState(() => _reorderableKeys = []);
    int connectionsLength =
        widget.connections == null ? 0 : widget.connections.length;
    int itemCount = connectionsLength > 0 ? connectionsLength : 1;
    for (int i = 0; i < itemCount; i++) {
      setState(() => _reorderableKeys.add(GlobalKey()));
    }
  }

  List<Widget> _getWidgetList() {
    _addKeys();
    List<Widget> widgets = [];
    if (widget.connections == null) {
      widget.connections = [];
    }

    bool addWidget(int index) {
      String searchQuery = Provider.of<HomeModel>(context).searchQuery;
      if (widget.connections.length <= 0) {
        return true;
      }
      if (searchQuery == "" ||
          widget.connections[index].name.contains(searchQuery) ||
          widget.connections[index].address.contains(searchQuery)) {
        return true;
      }
      return false;
    }

    int itemCount =
        widget.connections.length > 0 ? widget.connections.length : 1;
    for (int index = 0; index < itemCount; index++) {
      if (addWidget(index)) {
        widgets.add(
          Container(
            key: _reorderableKeys[index],
            child: widget.connections.length > 0
                ? ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    title: widget.connections[index].name != "" &&
                            widget.connections[index].name != "-"
                        ? Text(widget.connections[index].name)
                        : Text(widget.connections[index].address),
                    subtitle: Text(_getSubtitle(index)),
                    trailing: IconButton(
                      icon: Icon(
                        OMIcons.edit,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        ConnectionDialog(
                          context: context,
                          connection: widget.connections[index],
                          primaryButtonIconData: widget.isFavorites
                              ? OMIcons.edit
                              : Icons.star_border,
                          primaryButtonLabel:
                              widget.isFavorites ? "Edit" : "Add to favorites",
                          primaryButtonOnPressed: () {
                            if (widget.isFavorites) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      EditConnectionPage(index: index),
                                ),
                              );
                            } else {
                              HomePage.favoritesPage.insertConnection(
                                  0, widget.connections[index]);
                              setState(() {});
                              Navigator.pop(context);
                            }
                          },
                          hasSecondaryButton: true,
                          secondaryButtonIconData: OMIcons.delete,
                          secondaryButtonLabel: "Delete",
                          secondaryButtonOnPressed: () {
                            widget.removeConnectionAt(index);
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ).show();
                      },
                    ),
                    onTap: () async {
                      Provider.of<ConnectionModel>(context).isPasteMode = false;
                      Provider.of<ConnectionModel>(context).isCopyMode = false;
                      bool connected = await ConnectionMethods.connect(
                        context,
                        widget.connections[index],
                        callConnectClient: true,
                      );
                      if (!connected) {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 8),
                            content: Text("Failed to connect"),
                          ),
                        );
                      }
                    },
                  )
                : Container(),
          ),
        );
      }
    }
    return widgets;
  }

  bool _hasConnections() {
    if (widget.connections == null) return false;
    if (widget.connections.length <= 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ReorderableListView(
        header: !_hasConnections()
            ? Opacity(
                opacity: .7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        widget.isFavorites
                            ? "No favorite connections"
                            : "No recently added connections",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: OutlineButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        highlightedBorderColor: Colors.transparent,
                        highlightElevation: 6,
                        textColor: Theme.of(context).textTheme.body1.color,
                        icon: Icon(Icons.add, size: 22),
                        label: Text(
                          "Add a new connection",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  EditConnectionPage(isNew: true),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : (_getWidgetList().length <= 0
                ? Padding(
                    padding: EdgeInsets.all(30),
                    child: Opacity(
                      opacity: .7,
                      child: Text(
                        "No connections with this name or address",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : null),
        padding: EdgeInsets.only(top: 10),
        children: _getWidgetList(),
        onReorder: (int oldIndex, int newIndex) {
          var temp = widget.connections[oldIndex];
          setState(() {
            widget.removeConnectionAt(oldIndex);
            widget.insertConnection(
                newIndex - (oldIndex > newIndex ? 0 : 1), temp);
          });
        },
      ),
    );
  }
}
