import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../pages/pages.dart';
import '../services/services.dart';
import 'shared.dart';

class ConnectionBottomAppBar extends StatelessWidget {
  final ConnectionPage currentConnectionPage;
  final bool isSelectionMode;
  final GestureTapCallback cancelSelection;
  final GestureTapCallback deleteSelectedFiles;
  ConnectionBottomAppBar({
    @required this.currentConnectionPage,
    @required this.isSelectionMode,
    this.cancelSelection,
    this.deleteSelectedFiles,
  });

  @override
  Widget build(BuildContext context) {
    Widget _buildIconButtonLabel(String label) {
      return Opacity(
        opacity: .86,
        child: Text(
          label,
          style: TextStyle(
              color: isSelectionMode
                  ? Theme.of(context).accentIconTheme.color
                  : Theme.of(context).primaryIconTheme.color),
        ),
      );
    }

    var model = Provider.of<ConnectionModel>(context);
    Widget loadProgressWidget = AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: model.showProgress ? 50.0 : 0,
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 18.0, bottom: 12.0),
                  child: Text(
                    model.progressType == "download"
                        ? "Downloading ${model.loadFilename}"
                        : (model.progressType == "upload"
                            ? "Uploading ${model.loadFilename}"
                            : "Caching ${model.loadFilename}"),
                    style: TextStyle(
                      fontSize: 15.8,
                      fontWeight: FontWeight.w500,
                      color: Provider.of<CustomTheme>(context).isLightTheme()
                          ? Colors.grey[700]
                          : Colors.grey[200],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 18.0, right: 18.0, bottom: 12.0),
                child: Text(
                  "${model.progressValue}%",
                  style: TextStyle(
                    fontSize: 15.8,
                    fontWeight: FontWeight.w500,
                    color: Provider.of<CustomTheme>(context).isLightTheme()
                        ? Colors.grey[700]
                        : Colors.grey[200],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3.0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              value: model.progressValue.toDouble() * .01,
            ),
          ),
        ],
      ),
    );

    List<Widget> selectionModeItems = [];
    selectionModeItems.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: cancelSelection,
          ),
          _buildIconButtonLabel("Cancel"),
        ],
      ),
    );
    selectionModeItems.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Icon(OMIcons.delete),
            onPressed: deleteSelectedFiles,
          ),
          _buildIconButtonLabel("Delete"),
        ],
      ),
    );

    List<Widget> items = [];
    items.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          _buildIconButtonLabel("Back"),
        ],
      ),
    );
    items.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.youtube_searched_for),
            onPressed: () {
              customShowDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                    title: Text(
                      "Go to directory",
                      style: TextStyle(
                        fontFamily: SettingsVariables.accentFont,
                        fontSize: 18.0,
                      ),
                    ),
                    content: Container(
                      width: 260.0,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Path",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        cursorColor: Theme.of(context).accentColor,
                        autofocus: true,
                        autocorrect: false,
                        onSubmitted: (String value) {
                          ConnectionMethods.goToDirectory(
                            context,
                            value,
                            currentConnectionPage.connection,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          _buildIconButtonLabel("Go to directory"),
        ],
      ),
    );
    items.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Icon(OMIcons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage(
                      currentConnectionPage: currentConnectionPage,
                    );
                  },
                ),
              );
            },
          ),
          _buildIconButtonLabel("Settings"),
        ],
      ),
    );
    items.add(
      Column(
        children: <Widget>[
          IconButton(
            icon: Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Icon(OMIcons.flashOn),
            ),
            onPressed: () {
              ConnectionDialog(
                context: context,
                currentConnectionPage: currentConnectionPage,
                page: "connection",
                primaryButtonIconData: Icons.remove_circle_outline,
                primaryButtonLabel: "Disconnect",
                primaryButtonOnPressed: () {
                  if (!Platform.isIOS) model.client.disconnectSFTP();
                  model.client.disconnect();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ).show();
            },
          ),
          _buildIconButtonLabel("Connection"),
        ],
      ),
    );

    return BottomAppBar(
      child: Consumer<ConnectionModel>(
        builder: (context, model, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: (model.showProgress ? 50 : 0) + 65.0,
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                loadProgressWidget,
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 65,
                  margin: EdgeInsets.only(top: model.showProgress ? 50 : 0),
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: isSelectionMode ? selectionModeItems : items,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
