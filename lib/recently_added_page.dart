import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'favorites_page.dart';
import 'connection_page.dart';
import 'connection.dart';
import 'main.dart';

class RecentlyAddedPage extends StatefulWidget {
  static List<Connection> connections = [];

  @override
  _RecentlyAddedPageState createState() => _RecentlyAddedPageState();
}

class _RecentlyAddedPageState extends State<RecentlyAddedPage> {
  String _getSubtitle(int index) {
    String _output = "";
    bool _addressIsInOutput = false;
    if (index < RecentlyAddedPage.connections.length) {
      if (RecentlyAddedPage.connections[index].name != null) {
        _output += "Address: " + RecentlyAddedPage.connections[index].name;
        _addressIsInOutput = true;
      }
      if (RecentlyAddedPage.connections[index].port != "") {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: " + RecentlyAddedPage.connections[index].port;
      } else {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: 22";
      }
      if (RecentlyAddedPage.connections[index].username != "") {
        _output += ", Username: " + RecentlyAddedPage.connections[index].username;
      }
      if (RecentlyAddedPage.connections[index].path != "") {
        _output += ", Path: " + RecentlyAddedPage.connections[index].path;
      }
    }
    return _output;
  }

  List<GlobalKey> _reorderableKeys;

  void _addKeys() {
    setState(() => _reorderableKeys = []);
    int itemCount = RecentlyAddedPage.connections.length > 0 ? RecentlyAddedPage.connections.length : 1;
    for (int i = 0; i < itemCount; i++) {
      setState(() => _reorderableKeys.add(GlobalKey()));
    }
  }

  List<Widget> _getWidgetList() {
    _addKeys();
    List<Widget> widgets = [];
    int itemCount = RecentlyAddedPage.connections.length > 0 ? RecentlyAddedPage.connections.length : 1;
    for (int index = 0; index < itemCount; index++) {
      widgets.add(
        Container(
          key: _reorderableKeys[index],
          child: Padding(
            padding: EdgeInsets.only(
                top: index == 0 ? 10.0 : index == (RecentlyAddedPage.connections.length > 0 ? RecentlyAddedPage.connections.length : 1) ? 30.0 : .0),
            child: RecentlyAddedPage.connections.length > 0
                ? ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    title: RecentlyAddedPage.connections[index].name != ""
                        ? Text(RecentlyAddedPage.connections[index].name)
                        : Text(RecentlyAddedPage.connections[index].address),
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
                          page: "recentlyAdded",
                          primaryButton: RaisedButton(
                            color: Theme.of(context).accentColor,
                            splashColor: Colors.black12,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                                  child: Icon(
                                    Icons.star_border,
                                    size: 19.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Add to favorites",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                            padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                            elevation: .0,
                            onPressed: () {
                              setState(() {
                                FavoritesPage.connections.insert(0, RecentlyAddedPage.connections[index]);
                              });
                              MyHomePage.addToJson(RecentlyAddedPage.connections[index], true);
                              Navigator.pop(context);
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
                                RecentlyAddedPage.connections.removeAt(index);
                              });
                              MyHomePage.removeFromJsonAt(index, false);
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
                                  address: RecentlyAddedPage.connections[index].address,
                                  port: RecentlyAddedPage.connections[index].port,
                                  username: RecentlyAddedPage.connections[index].username,
                                  passwordOrKey: RecentlyAddedPage.connections[index].passwordOrKey,
                                  path: RecentlyAddedPage.connections[index].path,
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
                        "No connections added",
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
          var temp = RecentlyAddedPage.connections[a];
          setState(() {
            RecentlyAddedPage.connections.removeAt(a);
            RecentlyAddedPage.connections.insert(b - (a > b ? 0 : 1), temp);
            MyHomePage.removeFromJsonAt(a, false);
            MyHomePage.insertToJson(b - (a > b ? 0 : 1), temp, false);
          });
        },
      ),
    );
  }
}
