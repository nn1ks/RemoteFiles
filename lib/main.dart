import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_show_dialog.dart';
import 'new_connection.dart';
import 'tab_view_page.dart';
import 'connection_page.dart';
import 'connection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    Color accentColor = Colors.blueAccent[700];
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
            scaffoldBackgroundColor: Colors.white,
            accentColor: accentColor,
            primaryColor: Colors.white,
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
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
          //debugShowCheckedModeBanner: false,
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static TabViewPage favoritesPage = TabViewPage("favorites.json", true);
  static TabViewPage recentlyAddedPage = TabViewPage("recently_added.json", false);

  static Row _buildPasswordRow(int passwordLength) {
    if (passwordLength == 0) passwordLength = 1;
    List<Widget> widgets = [];
    for (int i = 0; i < passwordLength; i++) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(top: 8.0, right: 4.0),
          width: 4.0,
          height: 4.0,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Row(children: widgets);
  }

  static showConnectionDialog({
    @required BuildContext context,
    int index,
    @required String page,
    @required IconData primaryButtonIconData,
    @required String primaryButtonLabel,
    @required GestureTapCallback primaryButtonOnPressed,
    bool hasSecondaryButton = false,
    IconData secondaryButtonIconData,
    String secondaryButtonLabel,
    GestureTapCallback secondaryButtonOnPressed,
  }) {
    Connection values = Connection();
    if (page == "favorites") {
      values = MyHomePage.favoritesPage.connections[index];
    } else if (page == "recentlyAdded") {
      values = MyHomePage.recentlyAddedPage.connections[index];
    } else if (page == "connection") {
      values = ConnectionPage.currentConnection;
    }
    customShowDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Text(
            page == "connection" ? "Current connection" : (values.name != "" ? values.name : values.address),
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
                      page == "connection"
                          ? TableRow(children: [
                              Container(),
                              Container(),
                            ])
                          : TableRow(children: [
                              Text("Name:"),
                              Text(values.name != "" ? values.name : "-"),
                            ]),
                      TableRow(children: [
                        Text("Address:"),
                        Text(values.address),
                      ]),
                      TableRow(children: [
                        Text("Port:"),
                        Text(values.port),
                      ]),
                      TableRow(children: [
                        Text("Username:"),
                        Text(
                          values.username != "" ? values.username : "-",
                          style: TextStyle(),
                        )
                      ]),
                      TableRow(
                        children: [
                          Text("Password/Key:"),
                          values.passwordOrKey != "" ? _buildPasswordRow(values.passwordOrKey.length) : Text("-"),
                        ],
                      ),
                      TableRow(children: [
                        Text("Path:"),
                        Text(values.path),
                      ]),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            hasSecondaryButton
                ? FlatButton(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                          child: Icon(
                            secondaryButtonIconData,
                            size: 19.0,
                          ),
                        ),
                        Text(secondaryButtonLabel),
                      ],
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                    padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
                    onPressed: secondaryButtonOnPressed)
                : null,
            RaisedButton(
              color: Theme.of(context).accentColor,
              splashColor: Colors.black12,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 3.5, bottom: 2.0),
                    child: Icon(
                      primaryButtonIconData,
                      size: 19.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    primaryButtonLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 12.0, right: 14.0),
              elevation: .0,
              onPressed: primaryButtonOnPressed,
            ),
            SizedBox(width: .0),
          ],
        );
      },
    );
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  AnimationController _rotationController1;
  AnimationController _rotationController2;
  int _tabIndex = 0;

  _tabOnChange() {
    if (_tabIndex != _tabController.index) {
      if (_tabController.index == 0) {
        _rotationController1.forward(from: .0);
      } else if (_tabController.index == 1) {
        _rotationController2.forward(from: .0);
      }
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabOnChange);
    _rotationController1 = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _rotationController2 = AnimationController(duration: Duration(milliseconds: 280), vsync: this);
    getApplicationDocumentsDirectory().then((Directory dir) {
      setState(() {
        MyHomePage.favoritesPage.dir = dir;
        MyHomePage.recentlyAddedPage.dir = dir;
        MyHomePage.favoritesPage.jsonFile = File(MyHomePage.favoritesPage.dir.path + "/" + MyHomePage.favoritesPage.jsonFileName);
        MyHomePage.recentlyAddedPage.jsonFile = File(MyHomePage.recentlyAddedPage.dir.path + "/" + MyHomePage.recentlyAddedPage.jsonFileName);
        MyHomePage.favoritesPage.jsonFileExists = MyHomePage.favoritesPage.jsonFile.existsSync();
        MyHomePage.recentlyAddedPage.jsonFileExists = MyHomePage.recentlyAddedPage.jsonFile.existsSync();
        if (MyHomePage.favoritesPage.jsonFileExists) {
          MyHomePage.favoritesPage.connections = [];
          MyHomePage.favoritesPage.connections.addAll(MyHomePage.favoritesPage.getConnectionsFromJson());
        }
        if (MyHomePage.recentlyAddedPage.jsonFileExists) {
          MyHomePage.recentlyAddedPage.connections = [];
          MyHomePage.recentlyAddedPage.connections.addAll(MyHomePage.recentlyAddedPage.getConnectionsFromJson());
        }
      });
    });
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
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 2.8,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(18.0),
          child: TabBar(
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
                icon: RotationTransition(
                  turns: Tween(begin: .0, end: .2).animate(_rotationController1),
                  child: Icon(Icons.star_border),
                ),
                text: "Favorites",
              ),
              Tab(
                icon: RotationTransition(
                  turns: Tween(begin: .0, end: -1.0).animate(_rotationController2),
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.restore),
                  ),
                ),
                text: "Recently added",
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
              SizedBox(width: 6.0),
              InkWell(
                borderRadius: BorderRadius.circular(40.0),
                child: Padding(
                  padding: EdgeInsets.only(left: 14.0, right: 20.0, top: 7.0, bottom: 7.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset("assets/app_icon.png", width: 30.0),
                      SizedBox(width: 8.0),
                      Text(
                        "RemoteFiles",
                        style: TextStyle(fontFamily: "GoogleSans", fontWeight: FontWeight.w600, fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String version = packageInfo.version;
                  customShowDialog(
                    context: context,
                    builder: (context) {
                      return CustomAlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, .2), blurRadius: 2.0, offset: Offset(.0, .8))],
                              ),
                              width: 90.0,
                              height: 90.0,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Image.asset("assets/app_icon.png"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 18.0, bottom: 6.0),
                              child: Text(
                                "RemoteFiles",
                                style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "GoogleSans", fontSize: 19.0),
                              ),
                            ),
                            Text(
                              "Version: $version",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.6, color: Colors.grey[700]),
                            ),
                            Divider(height: 30.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    color: Color.fromRGBO(235, 240, 255, 1.0),
                                    splashColor: Color.fromRGBO(215, 225, 250, 1.0),
                                    elevation: .0,
                                    highlightElevation: 2.8,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: .8),
                                      child: Text(
                                        "GitHub",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13.6, fontFamily: "Roboto"),
                                      ),
                                    ),
                                    onPressed: () async {
                                      const url = "https://github.com/niklas-8/RemoteFiles";
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        Navigator.pop(context);
                                        _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text("Could not launch $url"),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 14.0,
                                ),
                                Expanded(
                                  child: RaisedButton(
                                    color: Color.fromRGBO(235, 240, 255, 1.0),
                                    splashColor: Color.fromRGBO(215, 225, 250, 1.0),
                                    elevation: .0,
                                    highlightElevation: 2.8,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: .8),
                                      child: Text(
                                        "PlayStore",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13.6, fontFamily: "Roboto"),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text("App is not yet available in the Google PlayStore"),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
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
          controller: _tabController,
          children: <Widget>[
            MyHomePage.favoritesPage,
            MyHomePage.recentlyAddedPage,
          ],
        ),
      ),
    );
  }
}
