import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'services/services.dart';
import 'shared/shared.dart';
import 'pages/pages.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => ConnectionModel()),
        ChangeNotifierProvider(builder: (context) => CustomTheme()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    MyApp.analytics
        .setUserProperty(name: "sort", value: "name (descending: true)");
    MyApp.analytics.setUserProperty(name: "view", value: "list");
    MyApp.analytics.setUserProperty(name: "theme", value: "automtic");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      title: 'RemoteFiles',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: MyApp.analytics),
      ],
      theme: Provider.of<CustomTheme>(context).themeValue == "dark"
          ? CustomThemes.dark
          : CustomThemes.light,
      darkTheme: Provider.of<CustomTheme>(context).themeValue == "light"
          ? CustomThemes.light
          : CustomThemes.dark,
    );
  }
}
