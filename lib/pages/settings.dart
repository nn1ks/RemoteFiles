import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/shared.dart';
import '../services/services.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildHeadline(String title, {bool hasSwitch = false, Function onChanged}) {
    return Padding(
      padding: EdgeInsets.only(top: hasSwitch ? 8.0 : 19.0, bottom: hasSwitch ? .0 : 11.0, left: 18.0, right: hasSwitch ? 22.0 : 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, fontFamily: "GoogleSans", letterSpacing: 1.0, color: Color.fromRGBO(0, 0, 0, .6)),
          ),
          hasSwitch
              ? Switch(
                  activeThumbImage: AssetImage("assets/arrow_drop_down.png"),
                  activeColor: Colors.grey[50],
                  activeTrackColor: Colors.grey[300],
                  inactiveThumbImage: AssetImage("assets/arrow_drop_up.png"),
                  inactiveTrackColor: Colors.grey[300],
                  inactiveThumbColor: Colors.grey[50],
                  value: SettingsVariables.sortIsDescending,
                  onChanged: onChanged,
                )
              : Container(),
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
                style: TextStyle(fontFamily: "GoogleSans", fontSize: 17.0, fontWeight: FontWeight.w600),
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
                                          icon: Icon(Icons.close, color: Colors.black87),
                                          onPressed: () {
                                            SettingsVariables.setDownloadDirectory("").then((_) => _downloadPathTextController.text = "");
                                          },
                                        ),
                                      ),
                                      CustomTooltip(
                                        message: "Set to default",
                                        child: CustomIconButton(
                                          icon: Icon(Icons.settings_backup_restore, color: Colors.black87),
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
                RadioListTile(
                  title: Text("List"),
                  groupValue: SettingsVariables.view,
                  value: "list",
                  onChanged: (String value) async {
                    await SettingsVariables.setView("list");
                    setState(() {});
                  },
                ),
                RadioListTile(
                  title: Text("Detailed"),
                  groupValue: SettingsVariables.view,
                  value: "detailed",
                  /*onChanged: (String value) async {
                    await SettingsVariables.setView("detailed");
                    setState(() {});
                  },*/
                ),
                RadioListTile(
                  title: Text("Grid"),
                  groupValue: SettingsVariables.view,
                  value: "grid",
                  onChanged: (String value) async {
                    SettingsVariables.setView("grid");
                    setState(() {});
                  },
                ),
                Divider(),
                _buildHeadline(
                  "Sort",
                  hasSwitch: true,
                  onChanged: (bool value) async {
                    await SettingsVariables.setSortIsDescending(value);
                    connectionModel.sort();
                    setState(() {});
                  },
                ),
                RadioListTile(
                  title: Text("Name"),
                  groupValue: SettingsVariables.sort,
                  value: "filename",
                  onChanged: (String value) async {
                    await SettingsVariables.setSort("filename");
                    connectionModel.sort();
                    setState(() {});
                  },
                ),
                RadioListTile(
                  title: Text("Modification Date"),
                  groupValue: SettingsVariables.sort,
                  value: "modificationDate",
                  onChanged: (String value) async {
                    await SettingsVariables.setSort("modificationDate");
                    connectionModel.sort();
                    setState(() {});
                  },
                ),
                RadioListTile(
                  title: Text("Last Access"),
                  groupValue: SettingsVariables.sort,
                  value: "lastAccess",
                  onChanged: (String value) async {
                    await SettingsVariables.setSort("lastAccess");
                    connectionModel.sort();
                    setState(() {});
                  },
                ),
                Divider(),
                _buildHeadline("Other"),
                CheckboxListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 3.0),
                    child: Text("Show hidden files"),
                  ),
                  value: SettingsVariables.showHiddenFiles,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowHiddenFiles(value);
                    setState(() {});
                  },
                ),
                CheckboxListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: 3.0),
                    child: Text("Show connection address in app bar"),
                  ),
                  value: SettingsVariables.showAddressInAppBar,
                  onChanged: (bool value) async {
                    await SettingsVariables.setShowAddressInAppBar(value);
                    setState(() {});
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
