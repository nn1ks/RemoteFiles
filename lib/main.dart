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
      theme: Provider.of<CustomTheme>(context).themeValue == "dark"
          ? (SettingsVariables.useAmoledDarkTheme
              ? CustomThemes.black
              : CustomThemes.dark)
          : CustomThemes.light,
      darkTheme: Provider.of<CustomTheme>(context).themeValue == "light"
          ? CustomThemes.light
          : (SettingsVariables.useAmoledDarkTheme
              ? CustomThemes.black
              : CustomThemes.dark),
    );
  }
}
