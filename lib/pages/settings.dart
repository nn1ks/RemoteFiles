import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'pages.dart';
import '../services/services.dart';
import '../shared/shared.dart';

class SettingsPage extends StatefulWidget {
  final ConnectionPage currentConnectionPage;

  SettingsPage({this.currentConnectionPage});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  Widget _buildHeadline(
    String title, {
    bool hasSwitch = false,
    Function onChanged,
  }) {
    String sortLabel;
    if (hasSwitch) {
      if (SettingsVariables.sort == "name") {
        if (SettingsVariables.sortIsDescending) {
          sortLabel = "(A-Z)";
        } else {
          sortLabel = "(Z-A)";
        }
      } else {
        if (SettingsVariables.sortIsDescending) {
          sortLabel = "(New-Old)";
        } else {
          sortLabel = "(Old-New)";
        }
      }
    }
    return Padding(
      padding: EdgeInsets.only(
        top: hasSwitch ? 0 : 12,
        bottom: hasSwitch ? 0 : 12,
        left: 16,
        right: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              letterSpacing: .7,
              color: Theme.of(context).accentColor,
            ),
          ),
          hasSwitch
              ? Row(
                  children: <Widget>[
                    Text(
                      sortLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        letterSpacing: .7,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    SizedBox(width: 6.0),
                    Switch(
                      activeColor: Theme.of(context).accentColor,
                      activeThumbImage:
                          AssetImage("assets/arrow_drop_down.png"),
                      inactiveThumbImage:
                          AssetImage("assets/arrow_drop_up.png"),
                      value: SettingsVariables.sortIsDescending,
                      onChanged: onChanged,
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildRadioListTile({
    @required String titleLabel,
    @required String value,
    @required bool isView,
  }) {
    return RadioListTile(
      activeColor: Theme.of(context).accentColor,
      title: Text(titleLabel),
      groupValue: isView ? SettingsVariables.view : SettingsVariables.sort,
      value: value,
      onChanged: (String radioValue) async {
        if (isView) {
          await SettingsVariables.setView(value);
        } else {
          await SettingsVariables.setSort(value);
          if (widget.currentConnectionPage != null) {
            widget.currentConnectionPage.sortFileInfos();
          }
        }
        setState(() {});
      },
    );
  }

  Widget _buildSaveToWidget() {
    if (Platform.isIOS) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeadline("Save files to"),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 4,
              bottom: 8,
            ),
            child: Container(
              child: TextField(
                controller: _downloadPathTextController,
                decoration: InputDecoration(
                  labelText: "Path",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).accentColor,
                      width: 2,
                    ),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomTooltip(
                        message: "Clear",
                        child: CustomIconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            SettingsVariables.setDownloadDirectory("").then(
                                (_) => _downloadPathTextController.text = "");
                          },
                        ),
                      ),
                      CustomTooltip(
                        message: "Set to default",
                        child: CustomIconButton(
                          icon: Icon(
                            Icons.settings_backup_restore,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            SettingsVariables.setDownloadDirectoryToDefault()
                                .then((Directory dir) {
                              _downloadPathTextController.text = dir.path;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: (String value) async {
                  await SettingsVariables.setDownloadDirectory(value);
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  var _downloadPathTextController =
      TextEditingController(text: SettingsVariables.downloadDirectory.path);

  var _moveCommandTextController =
      TextEditingController(text: SettingsVariables.moveCommand);
  var _copyCommandTextController =
      TextEditingController(text: SettingsVariables.copyCommand);

  String _moveCommandGroupValue =
      SettingsVariables.moveCommand == "mv" ? "default" : "custom";
  String _copyCommandGroupValue =
      SettingsVariables.copyCommand == "cp" ? "default" : "custom";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Provider.of<CustomTheme>(context).isLightTheme(context)
            ? Brightness.light
            : Brightness.dark,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        leading: Padding(
          padding: EdgeInsets.all(7),
          child: CustomIconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text("Settings", style: TextStyle(fontSize: 19)),
        titleSpacing: 4,
        elevation: 2,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 4),
                _buildHeadline("View"),
                _buildRadioListTile(
                  titleLabel: "List",
                  value: "list",
                  isView: true,
                ),
                _buildRadioListTile(
                  titleLabel: "Detailed",
                  value: "detailed",
                  isView: true,
                ),
                _buildRadioListTile(
                  titleLabel: "Grid",
                  value: "grid",
                  isView: true,
                ),
                Divider(),
                _buildHeadline(
                  "Sort",
                  hasSwitch: true,
                  onChanged: (bool value) async {
                    await SettingsVariables.setSortIsDescending(value);
                    if (widget.currentConnectionPage != null) {
                      widget.currentConnectionPage.sortFileInfos();
                    }
                    setState(() {});
                  },
                ),
                _buildRadioListTile(
                  titleLabel: "Name",
                  value: "name",
                  isView: false,
                ),
                _buildRadioListTile(
                  titleLabel: "Modification Date",
                  value: "modificationDate",
                  isView: false,
                ),
                _buildRadioListTile(
                  titleLabel: "Last Access",
                  value: "lastAccess",
                  isView: false,
                ),
                Divider(),
                _buildHeadline("Appearance"),
                ListTile(
                  title: Text("Theme"),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Opacity(
                      opacity: .6,
                      child: Text(Provider.of<CustomTheme>(context)
                              .themeValue[0]
                              .toUpperCase() +
                          Provider.of<CustomTheme>(context)
                              .themeValue
                              .substring(1)),
                    ),
                  ),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Consumer<CustomTheme>(
                              builder: (context, model, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RadioListTile(
                                  activeColor: Theme.of(context).accentColor,
                                  title: Text("Automatic"),
                                  subtitle: Text(
                                      "Chooses light or dark theme " +
                                          "based on your system settings"),
                                  value: "automatic",
                                  groupValue: model.themeValue,
                                  onChanged: (String value) async {
                                    await model.setThemeValue(value);
                                    setState(() {});
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Theme.of(context).accentColor,
                                  title: Text("Light"),
                                  value: "light",
                                  groupValue: model.themeValue,
                                  onChanged: (String value) async {
                                    await model.setThemeValue(value);
                                    setState(() {});
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Theme.of(context).accentColor,
                                  title: Text("Dark"),
                                  value: "dark",
                                  groupValue: model.themeValue,
                                  onChanged: (String value) async {
                                    await model.setThemeValue(value);
                                    setState(() {});
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Theme.of(context).accentColor,
                                  title: Text("Black"),
                                  value: "black",
                                  groupValue: model.themeValue,
                                  onChanged: (String value) async {
                                    await model.setThemeValue(value);
                                    setState(() {});
                                  },
                                ),
                              ],
                            );
                          });
                        }),
                      ),
                    );
                  },
                ),
                SwitchListTile(
                  activeColor: Theme.of(context).accentColor,
                  title: Text("Show dotfiles"),
                  subtitle: Text("Whether to show files that begin with a dot"),
                  value: SettingsVariables.showHiddenFiles,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowHiddenFiles(value);
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text("Unit for filesize"),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Opacity(
                      opacity: .6,
                      child: Text(
                          SettingsVariables.filesizeUnit[0].toUpperCase() +
                              SettingsVariables.filesizeUnit.substring(1)),
                    ),
                  ),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Automatic"),
                                value: "automatic",
                                groupValue: SettingsVariables.filesizeUnit,
                                onChanged: (String value) async {
                                  await SettingsVariables.setFilesizeUnit(
                                      value, widget.currentConnectionPage);
                                  setState(() {});
                                },
                              ),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Byte"),
                                value: "B",
                                groupValue: SettingsVariables.filesizeUnit,
                                onChanged: (String value) async {
                                  await SettingsVariables.setFilesizeUnit(
                                      value, widget.currentConnectionPage);
                                  setState(() {});
                                },
                              ),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Kilobyte"),
                                value: "KB",
                                groupValue: SettingsVariables.filesizeUnit,
                                onChanged: (String value) async {
                                  await SettingsVariables.setFilesizeUnit(
                                      value, widget.currentConnectionPage);
                                  setState(() {});
                                },
                              ),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Megabyte"),
                                value: "MB",
                                groupValue: SettingsVariables.filesizeUnit,
                                onChanged: (String value) async {
                                  await SettingsVariables.setFilesizeUnit(
                                      value, widget.currentConnectionPage);
                                  setState(() {});
                                },
                              ),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Gigabyte"),
                                value: "GB",
                                groupValue: SettingsVariables.filesizeUnit,
                                onChanged: (String value) async {
                                  await SettingsVariables.setFilesizeUnit(
                                      value, widget.currentConnectionPage);
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
                Divider(),
                _buildSaveToWidget(),
                Divider(),
                _buildHeadline("Shell commands"),
                ListTile(
                  title: Text("Move"),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Opacity(
                      opacity: .6,
                      child: Text(_moveCommandGroupValue[0].toUpperCase() +
                          _moveCommandGroupValue.substring(1)),
                    ),
                  ),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Default"),
                                subtitle: Text("Uses the shell command 'mv' " +
                                    "to move files and folders"),
                                value: "default",
                                groupValue: _moveCommandGroupValue,
                                onChanged: (String value) async {
                                  await SettingsVariables
                                      .setMoveCommandToDefault();
                                  await SettingsVariables.setMoveCommandAppend(
                                      false);
                                  setState(() {
                                    _moveCommandGroupValue = "default";
                                  });
                                },
                              ),
                              _moveCommandGroupValue == "custom"
                                  ? Divider()
                                  : Container(),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Custom"),
                                value: "custom",
                                groupValue: _moveCommandGroupValue,
                                onChanged: (String value) async {
                                  await SettingsVariables.setMoveCommand(
                                      _moveCommandTextController.text);
                                  setState(() {
                                    _moveCommandGroupValue = "custom";
                                  });
                                },
                              ),
                              _moveCommandGroupValue == "custom"
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 19, vertical: 10),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: "Shell command",
                                        ),
                                        controller: _moveCommandTextController,
                                        onChanged: (String value) async {
                                          await SettingsVariables
                                              .setMoveCommand(value);
                                        },
                                      ),
                                    )
                                  : Container(),
                              _moveCommandGroupValue == "custom"
                                  ? SwitchListTile(
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      title: Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Text(
                                          "Append '-r' when moving " +
                                              "directories",
                                        ),
                                      ),
                                      value:
                                          SettingsVariables.moveCommandAppend,
                                      onChanged: (bool value) async {
                                        await SettingsVariables
                                            .setMoveCommandAppend(value);
                                        setState(() {});
                                      },
                                    )
                                  : Container(),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text("Copy"),
                  trailing: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Opacity(
                      opacity: .6,
                      child: Text(_copyCommandGroupValue[0].toUpperCase() +
                          _copyCommandGroupValue.substring(1)),
                    ),
                  ),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                        content: StatefulBuilder(builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Default"),
                                subtitle: Text("Uses the shell command 'cp' " +
                                    "to copy files and 'cp -r' to copy " +
                                    "folders"),
                                value: "default",
                                groupValue: _copyCommandGroupValue,
                                onChanged: (String value) async {
                                  await SettingsVariables
                                      .setCopyCommandToDefault();
                                  await SettingsVariables.setCopyCommandAppend(
                                      true);
                                  setState(() {
                                    _copyCommandGroupValue = "default";
                                  });
                                },
                              ),
                              _copyCommandGroupValue == "custom"
                                  ? Divider()
                                  : Container(),
                              RadioListTile(
                                activeColor: Theme.of(context).accentColor,
                                title: Text("Custom"),
                                value: "custom",
                                groupValue: _copyCommandGroupValue,
                                onChanged: (String value) async {
                                  await SettingsVariables.setCopyCommand(
                                      _copyCommandTextController.text);
                                  setState(() {
                                    _copyCommandGroupValue = "custom";
                                  });
                                },
                              ),
                              _copyCommandGroupValue == "custom"
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 19, vertical: 10),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: "Shell command",
                                        ),
                                        controller: _copyCommandTextController,
                                        onChanged: (String value) async {
                                          await SettingsVariables
                                              .setCopyCommand(value);
                                        },
                                      ),
                                    )
                                  : Container(),
                              _copyCommandGroupValue == "custom"
                                  ? SwitchListTile(
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      title: Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Text(
                                          "Append '-r' when copying " +
                                              "directories",
                                        ),
                                      ),
                                      value:
                                          SettingsVariables.copyCommandAppend,
                                      onChanged: (bool value) async {
                                        await SettingsVariables
                                            .setCopyCommandAppend(value);
                                        setState(() {});
                                      },
                                    )
                                  : Container(),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
                Divider(),
                _buildHeadline("Miscellaneous"),
                ListTile(
                  title: Text("Delete all connections"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                        title: Text(
                          "Delete all connections?\nThis cannot be undone.",
                        ),
                        actions: <Widget>[
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: EdgeInsets.only(
                                top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          RaisedButton(
                            color: Theme.of(context).accentColor,
                            splashColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: EdgeInsets.only(
                                top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                            child: Text(
                              "OK",
                              style: TextStyle(
                                color: Provider.of<CustomTheme>(context)
                                        .isLightTheme(context)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            elevation: .0,
                            onPressed: () {
                              HomePage.favoritesPage.removeAllConnections();
                              HomePage.recentlyAddedPage.removeAllConnections();
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: .0),
                        ],
                      ),
                    );
                  },
                ),
                Divider(),
                _buildHeadline("About"),
                ListTile(
                  title: Text("About RemoteFiles"),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => AboutPage()),
                    );
                  },
                ),
                SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
