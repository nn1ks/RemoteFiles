import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/pages.dart';
import '../services/services.dart';
import 'shared.dart';

class AboutAppDialog extends StatelessWidget {
  final BuildContext context;
  final String version;
  AboutAppDialog(this.context, this.version);

  void show() {
    customShowDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, .2),
                  blurRadius: 2.0,
                  offset: Offset(.0, .8),
                )
              ],
            ),
            width: 90.0,
            height: 90.0,
            child: Padding(
              padding: EdgeInsets.all(15.79),
              child: Image.asset("assets/app_icon.png"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 18.0, bottom: 6.0),
            child: Text(
              "RemoteFiles",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: SettingsVariables.accentFont,
                fontSize: 19.0,
              ),
            ),
          ),
          Text(
            "Version: $version",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15.6,
              color: Theme.of(context).hintColor,
            ),
          ),
          Divider(height: 30.0),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Color.fromRGBO(235, 240, 255, 1)
                      : Color.fromRGBO(84, 88, 92, 1),
                  splashColor: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Color.fromRGBO(215, 225, 250, 1)
                      : Color.fromRGBO(100, 104, 110, 1),
                  elevation: .0,
                  highlightElevation: 2.8,
                  child: Padding(
                    padding: EdgeInsets.only(top: .8),
                    child: Text(
                      "GitHub",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.body1.color,
                        fontSize: 13.6,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    const url = "https://github.com/niklas-8/RemoteFiles";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      Navigator.pop(context);
                      HomePage.scaffoldKey.currentState.showSnackBar(
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
                  color: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Color.fromRGBO(235, 240, 255, 1)
                      : Color.fromRGBO(84, 88, 92, 1),
                  splashColor: Provider.of<CustomTheme>(context).isLightTheme()
                      ? Color.fromRGBO(215, 225, 250, 1)
                      : Color.fromRGBO(100, 104, 110, 1),
                  elevation: .0,
                  highlightElevation: 2.8,
                  child: Padding(
                    padding: EdgeInsets.only(top: .8),
                    child: Text(
                      "PlayStore",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.body1.color,
                        fontSize: 13.6,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    HomePage.scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          "App is not yet available in the Google PlayStore",
                        ),
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
  }
}
