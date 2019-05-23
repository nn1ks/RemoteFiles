import 'package:flutter/material.dart';
import 'connection.dart';
import 'main.dart';

class NewConnectionPage extends StatefulWidget {
  static Connection _connection = Connection();

  @override
  _NewConnectionPageState createState() => _NewConnectionPageState();
}

class _NewConnectionPageState extends State<NewConnectionPage> {
  bool _addToFavorites = false;
  bool _addressIsEntered = true;

  List<FocusNode> focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode(), FocusNode()];

  Container _buildTextField({String label, String hint, String valueText, bool isPassword = false, FocusNode focusNode, int index}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: TextField(
        focusNode: focusNodes[index],
        cursorColor: Theme.of(context).accentColor,
        obscureText: isPassword,
        textInputAction: label == "Path" ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
          labelText: label,
          hintText: hint,
          errorText: !_addressIsEntered && label == "Address*" ? "Please enter an address" : null,
        ),
        onChanged: (String value) {
          NewConnectionPage._connection.setter(valueText, value);
        },
        onSubmitted: (String value) {
          if (index < focusNodes.length - 1) FocusScope.of(context).requestFocus(focusNodes[index + 1]);
        },
      ),
    );
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
          if (NewConnectionPage._connection.address != null) {
            if (_addToFavorites) {
              MyHomePage.favoritesPage.addToJson(NewConnectionPage._connection);
              MyHomePage.favoritesPage.setConnectionsFromJson();
            }
            MyHomePage.recentlyAddedPage.addToJson(NewConnectionPage._connection);
            MyHomePage.favoritesPage.setConnectionsFromJson();
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
                margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 4.0),
                child: Column(children: <Widget>[
                  _buildTextField(label: "Name", valueText: "name", index: 0),
                  _buildTextField(label: "Address*", valueText: "address", index: 1),
                  _buildTextField(label: "Port", hint: "22", valueText: "port", index: 2),
                  _buildTextField(label: "Username", valueText: "username", index: 3),
                  _buildTextField(label: "Password or Key", valueText: "passwordOrKey", isPassword: true, index: 4),
                  _buildTextField(label: "Path", valueText: "path", index: 5),
                ]),
              ),
              CheckboxListTile(
                secondary: Icon(Icons.star_border),
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
