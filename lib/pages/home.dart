import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class HomePage extends StatefulWidget {
  static TabViewPage favoritesPage = TabViewPage(
    "favorites.json",
    true,
  );
  static TabViewPage recentlyAddedPage = TabViewPage(
    "recently_added.json",
    false,
  );

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        elevation: 2.8,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        title: Padding(
          padding: EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Text("RemoteFiles", style: TextStyle(fontSize: 18.6)),
              ),
              Row(
                children: <Widget>[
                  CustomTooltip(
                    message: "About",
                    child: CustomIconButton(
                      icon: Icon(OMIcons.info),
                      onPressed: () {
                        customShowDialog(
                          context: context,
                          builder: (context) => AboutAppDialog(context),
                        );
                      },
                    ),
                  ),
                  CustomTooltip(
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
                ],
              ),
            ],
          ),
        ),
        titleSpacing: 10,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(42.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 2),
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.withOpacity(.2),
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
            ],
          ),
        ),
      ),
      floatingActionButton: StatefulBuilder(builder: (context, setState) {
        return FloatingActionRow(
          heroTag: "fab",
          color: Theme.of(context).accentColor,
          children: <Widget>[
            CustomTooltip(
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
            CustomTooltip(
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
            HomePage.favoritesPage,
            HomePage.recentlyAddedPage,
          ],
        ),
      ),
    );
  }
}
