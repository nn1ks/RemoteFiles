import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'connection_page.dart';
import 'edit_connection.dart';
import 'connection.dart';
import 'main.dart';

class FavoritesPage extends StatefulWidget {
  static List<Connection> connections = [];

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _getSubtitle(int index) {
    String _output = "";
    bool _addressIsInOutput = false;
    if (index < FavoritesPage.connections.length) {
      if (FavoritesPage.connections[index].name != null) {
        _output += "Address: " + FavoritesPage.connections[index].address;
        _addressIsInOutput = true;
      }
      if (FavoritesPage.connections[index].port != "") {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: " + FavoritesPage.connections[index].port;
      } else {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: 22";
      }
      if (FavoritesPage.connections[index].username != "") {
        _output += ", Username: " + FavoritesPage.connections[index].username;
      }
      if (FavoritesPage.connections[index].path != "") {
        _output += ", Path: " + FavoritesPage.connections[index].path;
      }
    }
    return _output;
  }

  List<GlobalKey> _reorderableKeys;

  void _addKeys() {
    setState(() => _reorderableKeys = []);
    int itemCount = FavoritesPage.connections.length > 0 ? FavoritesPage.connections.length : 1;
    for (int i = 0; i < itemCount; i++) {
      setState(() => _reorderableKeys.add(GlobalKey()));
    }
  }

  List<Widget> _getWidgetList() {
    _addKeys();
    List<Widget> widgets = [];
    int itemCount = FavoritesPage.connections.length > 0 ? FavoritesPage.connections.length : 1;
    for (int index = 0; index < itemCount; index++) {
      widgets.add(
        Container(
          key: _reorderableKeys[index],
          child: Padding(
            padding:
                EdgeInsets.only(top: index == 0 ? 10.0 : index == (FavoritesPage.connections.length > 0 ? FavoritesPage.connections.length : 1) ? 30.0 : .0),
            child: FavoritesPage.connections.length > 0
                ? ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    title: FavoritesPage.connections[index].name != "" && FavoritesPage.connections[index].name != "-"
                        ? Text(FavoritesPage.connections[index].name)
                        : Text(FavoritesPage.connections[index].address),
                    subtitle: Text(_getSubtitle(index)),
                    trailing: IconButton(
                      icon: Icon(
                        OMIcons.edit,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        MyHomePage().showConnectionDialog(
                          context: context,
                          index: index,
                          page: "favorites",
                          primaryButton: RaisedButton(
                            color: Theme.of(context).accentColor,
                            splashColor: Colors.black12,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                  child: Icon(
                                    OMIcons.edit,
                                    size: 19.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                            elevation: .0,
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditConnectionPage(index),
                                ),
                              );
                            },
                          ),
                          hasSecondaryButton: true,
                          secondaryButton: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                  child: Icon(
                                    OMIcons.delete,
                                    size: 19.0,
                                  ),
                                ),
                                Text("Delete"),
                              ],
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                            onPressed: () {
                              setState(() {
                                FavoritesPage.connections.removeAt(index);
                              });
                              MyHomePage.removeFromJsonAt(index, true);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectionPage(
                                Connection(
                                  address: FavoritesPage.connections[index].address,
                                  port: FavoritesPage.connections[index].port,
                                  username: FavoritesPage.connections[index].username,
                                  passwordOrKey: FavoritesPage.connections[index].passwordOrKey,
                                  path: FavoritesPage.connections[index].path,
                                ),
                              ),
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Opacity(
                      opacity: .7,
                      child: Text(
                        "No favorites",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ReorderableListView(
        children: _getWidgetList(),
        onReorder: (int a, int b) {
          var temp = FavoritesPage.connections[a];
          setState(() {
            FavoritesPage.connections.removeAt(a);
            FavoritesPage.connections.insert(b - (a > b ? 0 : 1), temp);
            MyHomePage.removeFromJsonAt(a, true);
            MyHomePage.insertToJson(b - (a > b ? 0 : 1), temp, true);
          });
        },
      ),
    );
  }
}
