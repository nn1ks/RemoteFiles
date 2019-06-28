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
      CustomTooltip(
        message: "Cancel selection",
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => cancelSelection,
        ),
      ),
    );
    selectionModeItems.add(
      CustomTooltip(
        message: "Delete",
        child: IconButton(
          icon: Icon(OMIcons.delete),
          onPressed: () => deleteSelectedFiles,
        ),
      ),
    );

    List<Widget> items = [];
    items.add(
      CustomTooltip(
        message: "Back",
        child: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
    items.add(
      CustomTooltip(
        message: "Go to specific directory",
        child: IconButton(
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
      ),
    );
    items.add(
      CustomTooltip(
        message: "Settings",
        child: IconButton(
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
      ),
    );
    items.add(
      CustomTooltip(
        message: "Connection",
        child: IconButton(
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
      ),
    );

    return BottomAppBar(
      child: Consumer<ConnectionModel>(
        builder: (context, model, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: (model.showProgress ? 50.0 : 0) + 55.0,
            child: Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                loadProgressWidget,
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 55.0,
                  margin: EdgeInsets.only(top: model.showProgress ? 50.0 : 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
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
