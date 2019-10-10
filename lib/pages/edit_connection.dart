import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class EditConnectionPage extends StatefulWidget {
  final bool isNew;
  final int index;

  EditConnectionPage({this.isNew = false, this.index});

  @override
  _EditConnectionPageState createState() => _EditConnectionPageState();
}

class _EditConnectionPageState extends State<EditConnectionPage> {
  Connection _connection = Connection();

  bool _addToFavorites = true;
  bool _addressIsEntered = true;
  bool _usernameIsEntered = true;
  bool _passwordIsEntered = true;
  bool _passwordIsVisible = false;

  Map<String, TextEditingController> _textEditingController = {
    "name": TextEditingController(),
    "address": TextEditingController(),
    "port": TextEditingController(),
    "username": TextEditingController(),
    "password": TextEditingController(),
    "path": TextEditingController()
  };

  List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  Container _buildTextField({
    String label,
    String hint,
    String key,
    bool isPassword = false,
    FocusNode focusNode,
    int index,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: _textEditingController[key],
        focusNode: focusNodes[index],
        cursorColor: Theme.of(context).accentColor,
        obscureText: isPassword && !_passwordIsVisible,
        enableInteractiveSelection: true,
        autocorrect: key == "name",
        textInputAction:
            label == "Path" ? TextInputAction.done : TextInputAction.next,
        keyboardType: key == "port" ? TextInputType.numberWithOptions() : null,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 2.0),
          ),
          labelText: label,
          hintText: hint,
          errorText: (!_addressIsEntered && key == "address") ||
                  (!_usernameIsEntered && key == "username") ||
                  (!_passwordIsEntered && key == "password")
              ? "Please enter a $key"
              : null,
          suffixIcon: key == "password"
              ? CustomIconButton(
                  icon: Icon(_passwordIsVisible
                      ? OMIcons.visibilityOff
                      : OMIcons.visibility),
                  onPressed: () {
                    setState(() => _passwordIsVisible = !_passwordIsVisible);
                  },
                )
              : null,
        ),
        onChanged: (String value) {
          _connection.setter(key == "password" ? "passwordOrKey" : key, value);
        },
        onSubmitted: (String value) {
          if (index < focusNodes.length - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
        },
      ),
    );
  }

  @override
  void initState() {
    if (!widget.isNew) {
      Map<String, String> map = {};
      _textEditingController.forEach((k, v) {
        map.addAll(
            {k: HomePage.favoritesPage.connections[widget.index].toMap()[k]});
        _textEditingController[k].text =
            HomePage.favoritesPage.connections[widget.index].toMap()[k];
      });
      _connection = Connection.fromMap(map);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Provider.of<CustomTheme>(context).isLightTheme(context)
            ? Brightness.light
            : Brightness.dark,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        leading: Padding(
          padding: EdgeInsets.all(7),
          child: CustomIconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          widget.isNew ? "Add a new SFTP connection" : "Edit SFTP connection",
          style: TextStyle(fontSize: 19),
        ),
        titleSpacing: 4,
        elevation: 2,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        elevation: 4.0,
        child: Icon(Icons.done),
        onPressed: () {
          bool valid = true;
          setState(() {
            _addressIsEntered =
                _connection.address != null && _connection.address != "";
            _usernameIsEntered =
                _connection.username != null && _connection.username != "";
            _passwordIsEntered = _connection.passwordOrKey != null &&
                _connection.passwordOrKey != "";
            valid =
                _addressIsEntered && _usernameIsEntered && _passwordIsEntered;
          });
          if (valid) {
            if (widget.isNew) {
              if (_addToFavorites) {
                HomePage.favoritesPage.insertConnection(0, _connection);
              }
              HomePage.recentlyAddedPage.insertConnection(0, _connection);
              Navigator.pop(context);
            } else {
              HomePage.favoritesPage
                  .replaceConnectionAt(widget.index, _connection);
              Navigator.pop(context);
            }
            setState(() {});
          }
        },
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 20.0,
                    bottom: 4.0,
                  ),
                  child: Column(children: <Widget>[
                    _buildTextField(
                      label: "Name (optional)",
                      key: "name",
                      index: 0,
                    ),
                    _buildTextField(
                      label: "Address",
                      key: "address",
                      index: 1,
                    ),
                    _buildTextField(
                      label: "Port (optional, default: 22)",
                      hint: "22",
                      key: "port",
                      index: 2,
                    ),
                    _buildTextField(
                      label: "Username",
                      key: "username",
                      index: 3,
                    ),
                    _buildTextField(
                      label: "Password",
                      key: "password",
                      isPassword: true,
                      index: 4,
                    ),
                    _buildTextField(
                      label: "Path (optional, default: ~)",
                      hint: "~",
                      key: "path",
                      index: 5,
                    ),
                  ]),
                ),
                widget.isNew ? Divider() : Container(),
                widget.isNew
                    ? SwitchListTile(
                        activeColor: Theme.of(context).accentColor,
                        title: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Add to Favorites",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.4,
                            ),
                          ),
                        ),
                        value: _addToFavorites,
                        onChanged: (bool value) {
                          setState(() {
                            _addToFavorites = value;
                          });
                        },
                      )
                    : Container(),
                SizedBox(
                  height: 76.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
