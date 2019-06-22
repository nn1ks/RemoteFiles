import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../pages/pages.dart';
import '../services/services.dart';
import 'shared.dart';

class FileBottomSheet extends StatefulWidget {
  final Map<String, String> fileInfo;
  final ConnectionPage currentConnectionPage;
  FileBottomSheet(this.fileInfo, this.currentConnectionPage);

  @override
  _FileBottomSheetState createState() => _FileBottomSheetState();
}

class _FileBottomSheetState extends State<FileBottomSheet> {
  _showDeleteConfirmDialog(ConnectionModel model, String filePath) {
    customShowDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: Text(
            "Delete '${widget.fileInfo["filename"]}'?",
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
              onPressed: () async {
                if (widget.fileInfo["isDirectory"] == "true") {
                  await model.client.sftpRmdir(filePath);
                } else {
                  await model.client.sftpRm(filePath);
                }
                Navigator.pop(context);
                Navigator.pop(context);
                ConnectionMethods.refresh(context, widget.currentConnectionPage.connection);
              },
            ),
            SizedBox(width: .0),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String filePath = widget.currentConnectionPage.connection.path;
    if (widget.currentConnectionPage.connection.path.substring(widget.currentConnectionPage.connection.path.length - 2) != "/") filePath += "/";
    filePath += widget.fileInfo["filename"];

    double tableFontSize = 16.0;
    var renameController = TextEditingController(text: widget.fileInfo["filename"]);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 56.0,
                child: ListTile(
                  leading: Icon(widget.fileInfo["isDirectory"] == "true" ? Icons.folder_open : Icons.insert_drive_file),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        widget.fileInfo["filename"],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 1.0,
                color: Theme.of(context).dividerColor,
              ),
              Consumer<ConnectionModel>(builder: (context, model, child) {
                return Container(
                  height: constraints.maxHeight - 57.0,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Opacity(
                          opacity: .8,
                          child: Table(
                            columnWidths: {0: FixedColumnWidth(158.0)},
                            children: <TableRow>[
                              if (widget.fileInfo["isDirectory"] == "false")
                                TableRow(children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                      "Size:",
                                      style: TextStyle(fontSize: tableFontSize),
                                    ),
                                  ),
                                  Text(
                                    widget.fileInfo["convertedFileSize"],
                                    style: TextStyle(fontSize: tableFontSize),
                                  ),
                                ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    "Permissions:",
                                    style: TextStyle(fontSize: tableFontSize),
                                  ),
                                ),
                                Text(
                                  widget.fileInfo["permissions"],
                                  style: TextStyle(fontSize: tableFontSize),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    "Modification Date:",
                                    style: TextStyle(fontSize: tableFontSize),
                                  ),
                                ),
                                Text(
                                  widget.fileInfo["modificationDate"],
                                  style: TextStyle(fontSize: tableFontSize),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    "Last Access:",
                                    style: TextStyle(fontSize: tableFontSize),
                                  ),
                                ),
                                Text(
                                  widget.fileInfo["lastAccess"],
                                  style: TextStyle(fontSize: tableFontSize),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    "Path:",
                                    style: TextStyle(fontSize: tableFontSize),
                                  ),
                                ),
                                Text(
                                  widget.currentConnectionPage.connection.path + "/" + widget.fileInfo["filename"],
                                  style: TextStyle(fontSize: tableFontSize),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1.0,
                        margin: EdgeInsets.only(bottom: 8.0),
                        color: Theme.of(context).dividerColor,
                      ),
                      widget.fileInfo["isDirectory"] == "true"
                          ? Container()
                          : ListTile(
                              leading: Icon(Icons.open_in_new, color: Theme.of(context).accentColor),
                              title: Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Text(
                                  "Open",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                OpenFile.open(await LoadFile.saveInCache(filePath, model));
                              },
                            ),
                      widget.fileInfo["isDirectory"] == "true"
                          ? Container()
                          : Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.file_download, color: Theme.of(context).accentColor),
                                  title: Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      "Download",
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await LoadFile.download(context, filePath, widget.currentConnectionPage);
                                  },
                                ),
                              ],
                            ),
                      ListTile(
                        leading: Icon(OMIcons.edit, color: Theme.of(context).accentColor),
                        title: Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            "Rename",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () {
                          customShowDialog(
                            context: context,
                            builder: (context) {
                              return CustomAlertDialog(
                                title: Text(
                                  "Rename '${widget.fileInfo["filename"]}'",
                                  style: TextStyle(fontFamily: SettingsVariables.accentFont),
                                ),
                                content: TextField(
                                  controller: renameController,
                                  decoration: InputDecoration(
                                    labelText: "New name",
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                                    ),
                                  ),
                                  cursorColor: Theme.of(context).accentColor,
                                  autofocus: true,
                                  onSubmitted: (String value) async {
                                    String newFilePath = widget.currentConnectionPage.connection.path;
                                    if (widget.currentConnectionPage.connection.path.substring(widget.currentConnectionPage.connection.path.length - 2) !=
                                        "/") {
                                      newFilePath += "/";
                                    }
                                    newFilePath += value;
                                    await model.client.sftpRename(
                                      oldPath: filePath,
                                      newPath: newFilePath,
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ConnectionMethods.refresh(context, widget.currentConnectionPage.connection);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(OMIcons.delete, color: Theme.of(context).accentColor),
                        title: Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            "Delete",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        onTap: () => _showDeleteConfirmDialog(model, filePath),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
