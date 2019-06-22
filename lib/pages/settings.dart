import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/shared.dart';
import '../services/services.dart';
import 'pages.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  Widget _buildHeadline(String title, {bool hasSwitch = false, Function onChanged}) {
    return Padding(
      padding: EdgeInsets.only(top: hasSwitch ? 8.0 : 19.0, bottom: hasSwitch ? .0 : 11.0, left: 18.0, right: hasSwitch ? 22.0 : 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14.5, fontFamily: SettingsVariables.accentFont, letterSpacing: 1.0, color: Theme.of(context).hintColor),
          ),
          hasSwitch
              ? Switch(
                  activeThumbImage: AssetImage("assets/arrow_drop_down.png"),
                  activeColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[50] : Colors.grey[500],
                  activeTrackColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[300] : Colors.grey[700],
                  inactiveThumbImage: AssetImage("assets/arrow_drop_up.png"),
                  inactiveTrackColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[300] : Colors.grey[700],
                  inactiveThumbColor: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.grey[50] : Colors.grey[500],
                  value: SettingsVariables.sortIsDescending,
                  onChanged: onChanged,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildRadioListTile({@required String titleLabel, @required String value, @required bool isView}) {
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
          if (widget.currentConnectionPage != null) widget.currentConnectionPage.sort();
        }
        setState(() {});
      },
    );
  }

  Widget _buildCheckboxListTile({@required String titleLabel, @required bool value, @required ValueChanged<bool> onChanged}) {
    return CheckboxListTile(
      activeColor: Theme.of(context).accentColor,
      title: Padding(
        padding: EdgeInsets.only(left: 3.0),
        child: Text(titleLabel),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDetailedOptions() {
    return Padding(
      padding: EdgeInsets.only(left: 40.0),
      child: Column(
        children: <Widget>[
          Container(
            height: 1.0,
            margin: EdgeInsets.symmetric(horizontal: 18.0),
            color: Theme.of(context).dividerColor,
          ),
          RadioListTile(
            activeColor: Theme.of(context).accentColor,
            title: Text("Show modification date"),
            value: "modificationDate",
            groupValue: SettingsVariables.detailedViewTimeInfo,
            onChanged: (String value) async {
              await SettingsVariables.setDetailedViewTimeInfo(value);
              setState(() {});
            },
          ),
          RadioListTile(
            activeColor: Theme.of(context).accentColor,
            title: Text("Show last access"),
            value: "lastAccess",
            groupValue: SettingsVariables.detailedViewTimeInfo,
            onChanged: (String value) async {
              await SettingsVariables.setDetailedViewTimeInfo(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  var _downloadPathTextController = TextEditingController(text: SettingsVariables.downloadDirectory.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Settings",
                style: TextStyle(fontFamily: SettingsVariables.accentFont, fontSize: 17.0, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).detach(),
        child: SafeArea(
          child: Scrollbar(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 14.0),
                !Platform.isIOS
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildHeadline("Save files to:"),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 19.0, vertical: 4.0),
                            child: Container(
                              child: TextField(
                                controller: _downloadPathTextController,
                                decoration: InputDecoration(
                                  labelText: "Path",
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CustomTooltip(
                                        message: "Clear",
                                        child: CustomIconButton(
                                          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                                          onPressed: () {
                                            SettingsVariables.setDownloadDirectory("").then((_) => _downloadPathTextController.text = "");
                                          },
                                        ),
                                      ),
                                      CustomTooltip(
                                        message: "Set to default",
                                        child: CustomIconButton(
                                          icon: Icon(Icons.settings_backup_restore, color: Theme.of(context).iconTheme.color),
                                          onPressed: () {
                                            SettingsVariables.setDownloadDirectoryToDefault().then((Directory dir) {
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
                          Divider(),
                        ],
                      )
                    : Container(),
                _buildHeadline("View"),
                _buildRadioListTile(
                  titleLabel: "List",
                  value: "list",
                  isView: true,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  margin: EdgeInsets.symmetric(vertical: SettingsVariables.view == "detailed" ? 6.0 : .0),
                  decoration: BoxDecoration(
                    border: SettingsVariables.view == "detailed"
                        ? Border(
                            top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
                            bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
                        : null,
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildRadioListTile(
                        titleLabel: "Detailed",
                        value: "detailed",
                        isView: true,
                      ),
                      SettingsVariables.view == "detailed" ? _buildDetailedOptions() : Container(),
                    ],
                  ),
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
                    if (widget.currentConnectionPage != null) widget.currentConnectionPage.sort();
                    setState(() {});
                  },
                ),
                _buildRadioListTile(
                  titleLabel: "Name",
                  value: "filename",
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
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                            content: StatefulBuilder(builder: (context, setState) {
                              return Consumer<CustomTheme>(builder: (context, model, child) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RadioListTile(
                                      activeColor: Theme.of(context).accentColor,
                                      title: Text("Automatic"),
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
                                  ],
                                );
                              });
                            }),
                          ),
                    );
                  },
                ),
                /*ListTile(
                  title: Text("Font to use for headers"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                            content: StatefulBuilder(builder: (context, setState2) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("System default"),
                                    value: "default",
                                    groupValue: SettingsVariables.accentFont,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setAccentFont(value);
                                      setState2(() {});
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Overpass Mono", style: TextStyle(fontFamily: "OverpassMono")),
                                    value: "OverpassMono",
                                    groupValue: SettingsVariables.accentFont,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setAccentFont(value);
                                      setState2(() {});
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            }),
                          ),
                    );
                  },
                ),*/
                _buildCheckboxListTile(
                  titleLabel: "Show connection address in app bar",
                  value: SettingsVariables.showAddressInAppBar,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowAddressInAppBar(value);
                    setState(() {});
                  },
                ),
                Divider(),
                _buildHeadline("Other"),
                _buildCheckboxListTile(
                  titleLabel: "Show hidden files",
                  value: SettingsVariables.showHiddenFiles,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowHiddenFiles(value);
                    setState(() {});
                  },
                ),
                ListTile(
                  title: Text("Unit for filesize"),
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
                                      await SettingsVariables.setFilesizeUnit(value, Provider.of<ConnectionModel>(context));
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Byte"),
                                    value: "B",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setFilesizeUnit(value, Provider.of<ConnectionModel>(context));
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Kilobyte"),
                                    value: "KB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setFilesizeUnit(value, Provider.of<ConnectionModel>(context));
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Megabyte"),
                                    value: "MB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setFilesizeUnit(value, Provider.of<ConnectionModel>(context));
                                      setState(() {});
                                    },
                                  ),
                                  RadioListTile(
                                    activeColor: Theme.of(context).accentColor,
                                    title: Text("Gigabyte"),
                                    value: "GB",
                                    groupValue: SettingsVariables.filesizeUnit,
                                    onChanged: (String value) async {
                                      await SettingsVariables.setFilesizeUnit(value, Provider.of<ConnectionModel>(context));
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
                ListTile(
                  title: Text("Delete all connections"),
                  onTap: () {
                    customShowDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                            title: Text(
                              "Delete all connections?\nThis cannot be undone.",
                              style: TextStyle(fontFamily: SettingsVariables.accentFont),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                padding: EdgeInsets.only(top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              RaisedButton(
                                color: Theme.of(context).accentColor,
                                splashColor: Colors.black12,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                padding: EdgeInsets.only(top: 8.5, bottom: 8.0, left: 14.0, right: 14.0),
                                child: Text("OK", style: TextStyle(color: Provider.of<CustomTheme>(context).isLightTheme() ? Colors.white : Colors.black)),
                                elevation: .0,
                                onPressed: () {
                                  HomePage.favoritesPage.removeAllFromJson();
                                  HomePage.favoritesPage.setConnectionsFromJson();
                                  HomePage.recentlyAddedPage.removeAllFromJson();
                                  HomePage.recentlyAddedPage.setConnectionsFromJson();
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: .0),
                            ],
                          ),
                    );
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
