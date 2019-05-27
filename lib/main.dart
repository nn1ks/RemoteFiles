import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'services/services.dart';
import 'pages/pages.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    final Color accentColor = Colors.blueAccent[700];
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
            scaffoldBackgroundColor: Colors.white,
            accentColor: accentColor,
            accentColorBrightness: Brightness.dark,
            primaryColor: Colors.white,
            buttonColor: accentColor,
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
              labelStyle: TextStyle(fontSize: 16.0, color: Theme.of(context).hintColor),
              contentPadding: EdgeInsets.all(14.0),
            ),
            cursorColor: accentColor,
            dialogBackgroundColor: Colors.white,
            indicatorColor: accentColor,
            textSelectionHandleColor: accentColor,
            bottomAppBarTheme: BottomAppBarTheme(
              elevation: 8.0,
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
