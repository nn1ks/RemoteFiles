import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'custom_tooltip.dart';
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
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  static List<FlutterSecureStorage> favoriteStorageList = List.filled(FavoritesPage.favorites.length, FlutterSecureStorage());
  static List<FlutterSecureStorage> recentlyAddedStorageList = List.filled(RecentlyAddedPage.recentlyAdded.length, FlutterSecureStorage());

  writeFavoriteStorageList() async {
    for (int i = 0; i < FavoritesPage.favorites.length; i++) {
      List<String> keys = [];
      List<String> values = [];
      FavoritesPage.favorites[i].forEach((k, v) {
        keys.add(k);
        values.add(v);
      });
      for (int x = 0; x < FavoritesPage.favorites[i].length; x++) {
        await favoriteStorageList[i].write(key: keys[x], value: values[x]);
      }
    }
  }

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
      if (FavoritesPage.favorites[index]["name"] != "") values["name"] = FavoritesPage.favorites[index]["name"];
      if (FavoritesPage.favorites[index]["address"] != "") values["address"] = FavoritesPage.favorites[index]["address"];
      if (FavoritesPage.favorites[index]["port"] != "") values["port"] = FavoritesPage.favorites[index]["port"];
      if (FavoritesPage.favorites[index]["username"] != "") values["username"] = FavoritesPage.favorites[index]["username"];
      if (FavoritesPage.favorites[index]["passwordOrKey"] != "") values["passwordOrKey"] = FavoritesPage.favorites[index]["passwordOrKey"];
      if (FavoritesPage.favorites[index]["path"] != "") values["path"] = FavoritesPage.favorites[index]["path"];
    } else if (page == "recentlyAdded") {
      if (RecentlyAddedPage.recentlyAdded[index]["name"] != "") values["name"] = RecentlyAddedPage.recentlyAdded[index]["name"];
      if (RecentlyAddedPage.recentlyAdded[index]["address"] != "") values["address"] = RecentlyAddedPage.recentlyAdded[index]["address"];
      if (RecentlyAddedPage.recentlyAdded[index]["port"] != "") values["port"] = RecentlyAddedPage.recentlyAdded[index]["port"];
      if (RecentlyAddedPage.recentlyAdded[index]["username"] != "") values["username"] = RecentlyAddedPage.recentlyAdded[index]["username"];
      if (RecentlyAddedPage.recentlyAdded[index]["passwordOrKey"] != "") values["passwordOrKey"] = RecentlyAddedPage.recentlyAdded[index]["passwordOrKey"];
      if (RecentlyAddedPage.recentlyAdded[index]["path"] != "") values["path"] = RecentlyAddedPage.recentlyAdded[index]["path"];
    } else if (page == "connection") {
      if (ConnectionPage.currentConnection["name"] != "null") values["name"] = ConnectionPage.currentConnection["name"];
      if (ConnectionPage.currentConnection["address"] != "null") values["address"] = ConnectionPage.currentConnection["address"];
      if (ConnectionPage.currentConnection["port"] != "null") values["port"] = ConnectionPage.currentConnection["port"];
      if (ConnectionPage.currentConnection["username"] != "null") values["username"] = ConnectionPage.currentConnection["username"];
      if (ConnectionPage.currentConnection["passwordOrKey"] != "null") values["passwordOrKey"] = ConnectionPage.currentConnection["passwordOrKey"];
      if (ConnectionPage.currentConnection["path"] != "null") values["path"] = ConnectionPage.currentConnection["path"];
    }
    customShowDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Text(
              values["name"] != "-" ? values["name"] : values["address"],
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
                        TableRow(
                          children: [
                            Text("Password/Key:"),
                            values["passwordOrKey"] != "-"
                                ? Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: 8.0, right: 4.0),
                                        width: 4.0,
                                        height: 4.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 8.0, right: 4.0),
                                        width: 4.0,
                                        height: 4.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 8.0),
                                        width: 4.0,
                                        height: 4.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    ],
                                  )
                                : Text("-"),
                          ],
                        ),
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
              CustomTooltip(
                message: "Search",
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
              CustomTooltip(
                message: "About RemoteFiles",
                child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {},
                ),
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
