import 'dart:io';
import 'dart:convert';

import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class HomePage extends StatefulWidget {
  static TabViewPage favoritesPage = TabViewPage("favorites", true);
  static TabViewPage recentlyAddedPage = TabViewPage("recentlyAdded", false);

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isSearchMode = false;
  var _searchController = TextEditingController();

  TabController _tabController;

  bool _initIsDone = false;

  final _secureStorage = FlutterSecureStorage();

  Future<List<int>> _getEncryptionKey() async {
    String encryptionKey = await _secureStorage.read(key: "encryptionKey");
    if (encryptionKey == null) {
      encryptionKey = json.encode(Hive.generateSecureKey());
      _secureStorage.write(
        key: "encryptionKey",
        value: encryptionKey,
      );
    }
    return json.decode(encryptionKey).cast<int>();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    (Platform.isIOS
            ? getApplicationSupportDirectory()
            : getApplicationDocumentsDirectory())
        .then((Directory dir) {
      Hive.init(dir.path);
      Hive.registerAdapter(ConnectionAdapter(), 0);
      _getEncryptionKey().then((encryptionKey) {
        Hive.openBox("connections", encryptionKey: encryptionKey).then((box) {
          setState(() {
            HomePage.favoritesPage.init(box);
            HomePage.recentlyAddedPage.init(box);
            _initIsDone = true;
          });
        });
      });
    });
    SettingsVariables.initState();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CustomTheme>(context).setThemeValue(
        await Provider.of<CustomTheme>(context).getThemeValue(),
      );
    });
    return Scaffold(
      key: HomePage.scaffoldKey,
      resizeToAvoidBottomPadding: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 12,
                    top: 12,
                    right: 12,
                    bottom: 9,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomAppBarColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.4,
                        offset: Offset(0, .3),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _isSearchMode
                              ? Material(
                                  child: CustomIconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      Provider.of<HomeModel>(context)
                                          .searchQuery = "";
                                      _isSearchMode = false;
                                      setState(() {});
                                    },
                                  ),
                                )
                              : Container(),
                          _isSearchMode
                              ? SizedBox(
                                  width: constraints.maxWidth - 2 * 44,
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      focusColor: Theme.of(context).accentColor,
                                      hintText: "Search",
                                    ),
                                    onChanged: (String value) {
                                      Provider.of<HomeModel>(context)
                                          .searchQuery = value.trim();
                                      setState(() {});
                                    },
                                  ),
                                )
                              : Container(),
                          _isSearchMode
                              ? Container()
                              : Container(
                                  width: constraints.maxWidth - 2 * 44,
                                  padding: EdgeInsets.only(left: 14),
                                  child: Text(
                                    "RemoteFiles",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                          _isSearchMode
                              ? Container()
                              : Material(
                                  child: Tooltip(
                                    message: "Search",
                                    child: CustomIconButton(
                                      icon: Icon(Icons.search),
                                      onPressed: () {
                                        _isSearchMode = true;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                          Material(
                            child: Tooltip(
                              message: "Settings",
                              child: CustomIconButton(
                                icon: Icon(OMIcons.settings),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                TabBar(
                  indicator: MD2Indicator(
                    indicatorSize: MD2IndicatorSize.normal,
                    indicatorHeight: 3.4,
                    indicatorColor: Theme.of(context).accentColor,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 2.0,
                  labelColor: Theme.of(context).accentColor,
                  unselectedLabelColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.6,
                  ),
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(text: "Favorites"),
                    Tab(text: "Recently added"),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Theme.of(context).dividerColor,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: StatefulBuilder(builder: (context, setState) {
        return FloatingActionRow(
          heroTag: "fab",
          color: Theme.of(context).accentColor,
          children: <Widget>[
            Tooltip(
              message: "Quick connect",
              child: FloatingActionRowButton(
                icon: Icon(Icons.track_changes),
                onTap: () {
                  QuickConnectionSheet(
                    context,
                    onFail: () {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 5),
                          content: Text(
                            "Unable to connect",
                          ),
                        ),
                      );
                    },
                  ).show();
                },
              ),
            ),
            FloatingActionRowDivider(),
            Tooltip(
              message: "Add new connection",
              child: FloatingActionRowButton(
                icon: Icon(Icons.add),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return EditConnectionPage(isNew: true);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _initIsDone
                ? HomePage.favoritesPage
                : Center(child: CircularProgressIndicator()),
            _initIsDone
                ? HomePage.recentlyAddedPage
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
