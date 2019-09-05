import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/pages.dart';
import '../services/services.dart';
import 'shared.dart';

class AboutAppDialog extends StatefulWidget {
  final BuildContext context;

  AboutAppDialog(this.context);

  @override
  _AboutAppDialogState createState() => _AboutAppDialogState();
}

class _AboutAppDialogState extends State<AboutAppDialog> {
  String _version;
  bool _isLatestVersion;
  Map<dynamic, dynamic> _latestVersion;

  Future<bool> _getIsLatestVersion(Map<dynamic, dynamic> latestVersion) async {
    String latestVersionNumber = latestVersion["tag_name"].substring(1);
    for (int i = 0; i < latestVersionNumber.length; i++) {
      if (latestVersionNumber[i] == "-") {
        latestVersionNumber = latestVersionNumber.substring(0, i);
      }
    }
    if (_version == latestVersionNumber) {
      return true;
    }
    return false;
  }

  Future<Map<dynamic, dynamic>> _getLatestVersion() async {
    int convertTimeStringToInt(String publishedAt) {
      var timeString = "";
      for (int i = 0; i < publishedAt.length; i++) {
        if (i != 4 && i != 7 && i != 10 && i != 13 && i != 16 && i != 19) {
          timeString += publishedAt[i];
        }
      }
      return int.parse(timeString);
    }

    var result = await http.get(
      Uri.encodeFull(
        "https://api.github.com/repos/niklas-8/RemoteFiles/releases",
      ),
    );
    var content = json.decode(result.body);
    int latestIndex = 0;
    int latestTime =
        convertTimeStringToInt(content[latestIndex]["published_at"]);
    try {
      for (int i = 0; i < content.length; i++) {
        int time = convertTimeStringToInt(content[i]["published_at"]);
        if (time > latestTime) {
          latestTime = time;
          latestIndex = i;
        }
      }
      return content[latestIndex];
    } catch (e) {
      print(e);
    }
    return null;
  }

  Widget _buildVersionInfo() {
    Widget buildTopRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            _isLatestVersion ? Icons.check : Icons.error_outline,
            size: 18,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              _isLatestVersion
                  ? "You have the latest version"
                  : "You don't have the latest version",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      );
    }

    if (_isLatestVersion) {
      return buildTopRow();
    } else {
      String url = _latestVersion["html_url"];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(),
          SizedBox(height: 6),
          buildTopRow(),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: RichText(
                text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: "Download the latest version from GitHub",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (await canLaunch(url)) await launch(url);
                        }),
                  TextSpan(
                    text:
                        " or click the PlayStore button below to update the " +
                            "app",
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 15,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      _version = packageInfo.version;
      _getLatestVersion().then((latestVersion) async {
        _latestVersion = latestVersion;
        _isLatestVersion = await _getIsLatestVersion(latestVersion);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, .24),
                    blurRadius: 2.6,
                    offset: Offset(.0, .6),
                  )
                ],
              ),
              width: 68,
              height: 68,
              child: Padding(
                padding: EdgeInsets.all(11.6),
                child: Image.asset("assets/app_icon.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 6),
              child: Text(
                "RemoteFiles",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                ),
              ),
            ),
            Text(
              "Version: $_version",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Theme.of(context).hintColor,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 230),
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: _isLatestVersion == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 11,
                            height: 11,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.4,
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Checking for updates...",
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : _buildVersionInfo(),
              ),
            ),
            Divider(height: 30.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    color:
                        Provider.of<CustomTheme>(context).isLightTheme(context)
                            ? Color.fromRGBO(235, 240, 255, 1)
                            : Color.fromRGBO(84, 88, 92, 1),
                    splashColor:
                        Provider.of<CustomTheme>(context).isLightTheme(context)
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
                    color:
                        Provider.of<CustomTheme>(context).isLightTheme(context)
                            ? Color.fromRGBO(235, 240, 255, 1)
                            : Color.fromRGBO(84, 88, 92, 1),
                    splashColor:
                        Provider.of<CustomTheme>(context).isLightTheme(context)
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
      ),
    );
  }
}
