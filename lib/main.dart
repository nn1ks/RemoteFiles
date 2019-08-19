import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  ThemeData _getLightTheme(CustomTheme model) {
    if (model.themeValue == "dark") {
      return CustomThemes.dark;
    } else if (model.themeValue == "black") {
      return CustomThemes.black;
    } else {
      return CustomThemes.light;
    }
  }

  ThemeData _getDarkTheme(CustomTheme model) {
    if (model.themeValue == "light") {
      return CustomThemes.light;
    } else if (model.themeValue == "black") {
      return CustomThemes.black;
    } else {
      return CustomThemes.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'RemoteFiles',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
      theme: _getLightTheme(Provider.of<CustomTheme>(context)),
      darkTheme: _getDarkTheme(Provider.of<CustomTheme>(context)),
    );
  }
}
