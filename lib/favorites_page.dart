import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'connection_page.dart';
import 'edit_connection.dart';
import 'connection.dart';
import 'main.dart';

class FavoritesPage extends StatefulWidget {
  static List<Map<String, String>> favorites = [];

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String _getSubtitle(int index) {
    String _output = "";
    bool _addressIsInOutput = false;
    if (index < FavoritesPage.favorites.length) {
      if (FavoritesPage.favorites[index]["name"] != null) {
        _output += "Address: " + FavoritesPage.favorites[index]["address"];
        _addressIsInOutput = true;
      }
      if (FavoritesPage.favorites[index]["port"] != "") {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: " + FavoritesPage.favorites[index]["port"];
      } else {
        if (_addressIsInOutput) {
          _output += ", ";
        }
        _output += "Port: 22";
      }
      if (FavoritesPage.favorites[index]["username"] != "") {
        _output += ", Username: " + FavoritesPage.favorites[index]["username"];
      }
      if (FavoritesPage.favorites[index]["path"] != "") {
        _output += ", Path: " + FavoritesPage.favorites[index]["path"];
      }
    }
    return _output;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: FavoritesPage.favorites.length > 0 ? FavoritesPage.favorites.length : 1,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 10.0 : index == (FavoritesPage.favorites.length > 0 ? FavoritesPage.favorites.length : 1) ? 30.0 : .0),
            child: FavoritesPage.favorites.length > 0
                ? ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    title: FavoritesPage.favorites[index]["name"] != ""
                        ? Text(FavoritesPage.favorites[index]["name"])
                        : Text(FavoritesPage.favorites[index]["address"]),
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
                                FavoritesPage.favorites.removeAt(index);
                              });
                              MyHomePage.removeConnection(index, true);
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
                                  address: FavoritesPage.favorites[index]["address"],
                                  port: FavoritesPage.favorites[index]["port"],
                                  username: FavoritesPage.favorites[index]["username"],
                                  passwordOrKey: FavoritesPage.favorites[index]["passwordOrKey"],
                                  path: FavoritesPage.favorites[index]["path"],
                                ),
                              ),
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 20.0),
                    child: Opacity(
                      opacity: .7,
                      child: Text(
                        "No favorites",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
