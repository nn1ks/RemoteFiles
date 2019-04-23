import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'recently_added_page.dart';
import 'connection.dart';
import 'main.dart';

class NewConnectionPage extends StatefulWidget {
  @override
  _NewConnectionPageState createState() => _NewConnectionPageState();
}

class _NewConnectionPageState extends State<NewConnectionPage> {
  bool _addToFavorites = false;
  bool _addressIsEntered = true;

  String _name = "";
  String _address;
  String _port = "";
  String _username = "";
  String _passwordOrKey = "";
  String _path = "~/";

  Container _buildTextField({String label, String hint, String onChangedText, bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: TextField(
        cursorColor: Theme.of(context).accentColor,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
          labelText: label,
          hintText: hint,
          errorText: !_addressIsEntered && label == "Address*" ? "Please enter an address" : null,
        ),
        obscureText: isPassword,
        onChanged: (String value) {
          _onTextFieldChanged(value, onChangedText);
        },
      ),
    );
  }

  _onTextFieldChanged(String value, String title) {
    setState(() {
      switch (title) {
        case "name":
          _name = value;
          break;
        case "address":
          _address = value;
          break;
        case "port":
          _port = value;
          break;
        case "username":
          _username = value;
          break;
        case "passwordOrKey":
          _passwordOrKey = value;
          break;
        case "path":
          _path = value;
          break;
      }
    });
  }

  Map<String, String> _getConnectionMap() {
    print({
      "address": _address,
      "port": _port != null ? _port : "22",
      "username": _username,
      "passwordOrKey": _passwordOrKey,
      "path": _path != null ? _path : "./",
      "name": _name
    });
    return {
      "address": _address,
      "port": _port != null ? _port : "22",
      "username": _username,
      "passwordOrKey": _passwordOrKey,
      "path": _path != null ? _path : "./",
      "name": _name
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        elevation: 8.0,
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                "Add a new SFTP connection",
                style: TextStyle(fontFamily: "GoogleSans", fontSize: 17.0, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        elevation: 4.0,
        child: Icon(Icons.done),
        onPressed: () {
          if (_address != null) {
            if (_addToFavorites) {
              setState(() {
                FavoritesPage.favorites.insert(0, {});
                FavoritesPage.favorites[0].addAll(_getConnectionMap());
                MyHomePage().writeFavoriteStorageList();
              });
            }
            RecentlyAddedPage.recentlyAdded.insert(0, {});
            RecentlyAddedPage.recentlyAdded[0].addAll(_getConnectionMap());
            ConnectionPage().connectToSftpMap(_getConnectionMap());
            Navigator.pop(context);
          } else {
            setState(() {
              _addressIsEntered = false;
            });
          }
        },
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(20.0),
                  child: Column(children: <Widget>[
                    _buildTextField(label: "Name", onChangedText: "name"),
                    _buildTextField(label: "Address*", onChangedText: "address"),
                    _buildTextField(label: "Port", hint: "22", onChangedText: "port"),
                    _buildTextField(label: "Username", onChangedText: "username"),
                    _buildTextField(label: "Password or Key", onChangedText: "passwordOrKey", isPassword: true),
                    _buildTextField(label: "Path", onChangedText: "path"),
                  ])),
              CheckboxListTile(
                secondary: Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(Icons.star_border),
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    "Add to Favorites",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.4),
                  ),
                ),
                value: _addToFavorites,
                onChanged: (bool value) {
                  setState(() {
                    _addToFavorites = value;
                  });
                },
              ),
              ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(Icons.add_circle_outline),
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text("Add template"),
                ),
                onTap: () {
                  FavoritesPage.favorites.insert(0, {});
                  FavoritesPage.favorites[0].addAll({
                    "address": "192.168.2.2",
                    "port": "22",
                    "username": "niklas",
                    "passwordOrKey": "esse850ni",
                    "path": "/mnt/server-hdd/niklas",
                    "name": "fileserver local"
                  });
                  //MyHomePage().writeFavoriteStorageList();
                  RecentlyAddedPage.recentlyAdded.insert(0, {});
                  RecentlyAddedPage.recentlyAdded[0].addAll({
                    "address": "192.168.2.2",
                    "port": "22",
                    "username": "niklas",
                    "passwordOrKey": "esse850ni",
                    "path": "/mnt/server-hdd/niklas",
                    "name": "fileserver local"
                  });
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 76.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
