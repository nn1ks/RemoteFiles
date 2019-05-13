import 'package:RemoteFiles/sftp_connection.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'custom_show_dialog.dart';
import 'load_file.dart';
import 'sftp_connection.dart';
import 'connection.dart';

class FileBottomSheet extends StatefulWidget {
  FileBottomSheet(int index) {
    _FileBottomSheetState()._setIndex(index);
  }

  @override
  _FileBottomSheetState createState() => _FileBottomSheetState();
}

class _FileBottomSheetState extends State<FileBottomSheet> {
  bool isDirectory = SftpConnection.fileInfos[0]["isDirectory"] == "true";
  String filePath = SftpConnection.currentConnection["path"];
  double _tableFontSize = 16.0;
  int index;

  _setIndex(int index) {
    this.index = index;
  }

  _showDeleteConfirmDialog(int index, String filePath) {
    customShowDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: Text(
            "Delete '${SftpConnection.fileInfos[index]["filename"]}'?",
            style: TextStyle(fontFamily: "GoogleSans"),
          ),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
              child: Row(
                children: <Widget>[
                  Text("Cancel"),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              splashColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.only(top: 8.0, bottom: 6.5, left: 14.0, right: 14.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              elevation: .0,
              onPressed: () async {
                if (SftpConnection.fileInfos[index]["isDirectory"] == "true") {
                  await SftpConnection.client.sftpRmdir(filePath);
                } else {
                  await SftpConnection.client.sftpRm(filePath);
                }
                Navigator.pop(context);
                Navigator.pop(context);
                SftpConnection.connectMap(SftpConnection.currentConnection);
              },
            ),
            SizedBox(width: .0),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    isDirectory = SftpConnection.fileInfos[0]["isDirectory"] == "true";
    filePath = SftpConnection.currentConnection["path"];
    if (SftpConnection.currentConnection["path"].substring(SftpConnection.currentConnection["path"].length - 2) != "/") {
      filePath += "/";
    }
    filePath += SftpConnection.fileInfos[0]["filename"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 56.0,
                child: ListTile(
                  leading: Icon(isDirectory ? Icons.folder_open : Icons.insert_drive_file),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        SftpConnection.fileInfos[index]["filename"],
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
              Container(
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
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  "Permissions:",
                                  style: TextStyle(fontSize: _tableFontSize),
                                ),
                              ),
                              Text(
                                SftpConnection.fileInfos[index]["permissions"],
                                style: TextStyle(fontSize: _tableFontSize),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  "Modification Date:",
                                  style: TextStyle(fontSize: _tableFontSize),
                                ),
                              ),
                              Text(
                                SftpConnection.fileInfos[index]["modificationDate"],
                                style: TextStyle(fontSize: _tableFontSize),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  "Last Access:",
                                  style: TextStyle(fontSize: _tableFontSize),
                                ),
                              ),
                              Text(
                                SftpConnection.fileInfos[index]["lastAccess"],
                                style: TextStyle(fontSize: _tableFontSize),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  "Path:",
                                  style: TextStyle(fontSize: _tableFontSize),
                                ),
                              ),
                              Text(
                                SftpConnection.currentConnection["path"] + "/" + SftpConnection.fileInfos[index]["filename"],
                                style: TextStyle(fontSize: _tableFontSize),
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
                    isDirectory
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
                                  if (!await LoadFile.download(filePath)) {
                                    ConnectionPage.scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 3),
                                        content: Text("Download failed"),
                                      ),
                                    );
                                  }
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
                                "Rename '${SftpConnection.fileInfos[index]["filename"]}'",
                                style: TextStyle(fontFamily: "GoogleSans"),
                              ),
                              content: TextField(
                                decoration: InputDecoration(
                                  labelText: "New name",
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
                                  ),
                                ),
                                cursorColor: Theme.of(context).accentColor,
                                autofocus: true,
                                onSubmitted: (String value) async {
                                  String newFilePath = SftpConnection.currentConnection["path"];
                                  if (SftpConnection.currentConnection["path"].substring(SftpConnection.currentConnection["path"].length - 2) != "/") {
                                    newFilePath += "/";
                                  }
                                  newFilePath += value;
                                  await SftpConnection.client.sftpRename(
                                    oldPath: filePath,
                                    newPath: newFilePath,
                                  );
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  SftpConnection.connectMap(SftpConnection.currentConnection);
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
                      onTap: () => _showDeleteConfirmDialog(index, filePath),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
