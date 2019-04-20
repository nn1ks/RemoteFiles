import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'custom_show_dialog.dart';
import 'new_connection.dart';
import 'connection.dart';
import 'favorites_page.dart';
import 'recently_added_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
              scaffoldBackgroundColor: Colors.white,
              accentColor: Colors.blueAccent[700],
              primaryColor: Colors.white,
              buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                buttonColor: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                labelStyle: TextStyle(fontSize: 16.0, color: Theme.of(context).hintColor),
                contentPadding: EdgeInsets.all(14.0),
              ),
              textTheme: TextTheme(
                button: TextStyle(fontFamily: "GoogleSans"),
              ),
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'RemoteFiles',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: MyHomePage(title: 'RemoteFiles'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  static List<Map<String, String>> favorites = [];
  static List<Map<String, String>> recentlyAdded = [];

  showConnectionDialog({
    @required BuildContext context,
    int index,
    @required String page,
    @required Widget primaryButton,
    bool hasSecondaryButton = false,
    Widget secondaryButton,
  }) {
    Map<String, String> values = {
      "name": "-",
      "address": "-",
      "port": "22",
      "username": "-",
      "passwordOrKey": "-",
      "path": "-",
    };
    if (page == "favorites") {
      if (FavoritesPage.favorites[index]["name"] != null) values["name"] = FavoritesPage.favorites[index]["name"];
      if (FavoritesPage.favorites[index]["addres"] != null) values["addres"] = FavoritesPage.favorites[index]["addres"];
      if (FavoritesPage.favorites[index]["port"] != null) values["port"] = FavoritesPage.favorites[index]["port"];
      if (FavoritesPage.favorites[index]["username"] != null) values["username"] = FavoritesPage.favorites[index]["username"];
      if (FavoritesPage.favorites[index]["passwordOrKey"] != null) values["passwordOrKey"] = FavoritesPage.favorites[index]["passwordOrKey"];
      if (FavoritesPage.favorites[index]["path"] != null) values["path"] = FavoritesPage.favorites[index]["path"];
    } else if (page == "recentlyAdded") {
      if (RecentlyAddedPage.recentlyAdded[index]["name"] != null) values["name"] = RecentlyAddedPage.recentlyAdded[index]["name"];
      if (RecentlyAddedPage.recentlyAdded[index]["addres"] != null) values["addres"] = RecentlyAddedPage.recentlyAdded[index]["addres"];
      if (RecentlyAddedPage.recentlyAdded[index]["port"] != null) values["port"] = RecentlyAddedPage.recentlyAdded[index]["port"];
      if (RecentlyAddedPage.recentlyAdded[index]["username"] != null) values["username"] = RecentlyAddedPage.recentlyAdded[index]["username"];
      if (RecentlyAddedPage.recentlyAdded[index]["passwordOrKey"] != null) values["passwordOrKey"] = RecentlyAddedPage.recentlyAdded[index]["passwordOrKey"];
      if (RecentlyAddedPage.recentlyAdded[index]["path"] != null) values["path"] = RecentlyAddedPage.recentlyAdded[index]["path"];
    } else if (page == "connection") {
      if (ConnectionPage.currentConnection["name"] != null) values["name"] = ConnectionPage.currentConnection["name"];
      if (ConnectionPage.currentConnection["addres"] != null) values["addres"] = ConnectionPage.currentConnection["addres"];
      if (ConnectionPage.currentConnection["port"] != null) values["port"] = ConnectionPage.currentConnection["port"];
      if (ConnectionPage.currentConnection["username"] != null) values["username"] = ConnectionPage.currentConnection["username"];
      if (ConnectionPage.currentConnection["passwordOrKey"] != null) values["passwordOrKey"] = ConnectionPage.currentConnection["passwordOrKey"];
      if (ConnectionPage.currentConnection["path"] != null) values["path"] = ConnectionPage.currentConnection["path"];
    }
    customShowDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Text(
              values["name"],
              style: TextStyle(
                fontFamily: "GoogleSans",
              ),
            ),
            content: Container(
              width: 400.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Opacity(
                    opacity: .8,
                    child: Table(
                      columnWidths: {0: FixedColumnWidth(120.0)},
                      children: [
                        TableRow(children: [Text("Name:"), Text(values["name"])]),
                        TableRow(children: [Text("Address:"), Text(values["address"])]),
                        TableRow(children: [
                          Text("Port:"),
                          Text(values["port"]),
                        ]),
                        TableRow(children: [
                          Text("Username:"),
                          Text(
                            values["username"],
                            style: TextStyle(),
                          )
                        ]),
                        values["passwordOrKey"] != "-"
                            ? TableRow(
                                children: [
                                  Text("Password/Key:"),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 7.0, right: 3.0),
                                        width: 6.0,
                                        height: 6.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 7.0, right: 3.0),
                                        width: 6.0,
                                        height: 6.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 7.0, right: 3.0),
                                        width: 6.0,
                                        height: 6.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            : Container(),
                        TableRow(children: [
                          Text("Path:"),
                          Text(values["path"]),
                        ]),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              hasSecondaryButton ? secondaryButton : Container(),
              primaryButton,
              SizedBox(
                width: .0,
              ),
            ],
          );
        });
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController _tabController;

  _addFavorite({@required String address, String port, String username, String passwordOrKey, String path, String name}) {
    setState(() {
      FavoritesPage.favorites.add({
        "address": address,
        "port": port,
        "username": username,
        "passwordOrKey": passwordOrKey,
        "path": path,
        "name": name,
      });
    });
  }

  _addRecentlyAdded({@required String address, String port, String username, String passwordOrKey, String path, String name}) {
    setState(() {
      RecentlyAddedPage.recentlyAdded.add({
        "address": address,
        "port": port,
        "username": username,
        "passwordOrKey": passwordOrKey,
        "path": path,
        "name": name,
      });
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.7,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TabBar(
                indicator: MD2Indicator(
                  indicatorSize: MD2IndicatorSize.normal,
                  indicatorHeight: 3.4,
                  indicatorColor: Theme.of(context).accentColor,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,
                labelColor: Theme.of(context).accentColor,
                unselectedLabelColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
                labelStyle: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w700, fontSize: 14.0),
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.star_border),
                        SizedBox(width: 8.0),
                        Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Text("Favorites"),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.restore),
                        SizedBox(width: 8.0),
                        Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Text("Recently added"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        elevation: 8.0,
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 18.0, right: 10.0),
                child: Text(
                  "RemoteFiles",
                  style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w600, fontSize: 17.0),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  _addFavorite(address: "192.168.2.2", username: "niklas", passwordOrKey: "esse850ni", path: "/mnt/server-hdd/niklas", name: "fileserver");
                  _addRecentlyAdded(address: "192.168.2.2", username: "niklas", passwordOrKey: "esse850ni", path: "/mnt/server-hdd/niklas", name: "fileserver");
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        elevation: 4.0,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewConnectionPage()));
        },
      ),
      body: SafeArea(
        child: TabBarView(
          physics: BouncingScrollPhysics(),
          controller: _tabController,
          children: <Widget>[
            FavoritesPage(),
            RecentlyAddedPage(),
          ],
        ),
      ),
    );
  }
}
