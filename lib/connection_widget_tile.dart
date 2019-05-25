import 'package:flutter/material.dart';
import 'custom_icon_button.dart';

class ConnectionWidgetTile extends StatefulWidget {
  final int index;
  final List<Map<String, String>> fileInfos;
  final bool isLoading;
  final bool isListView;
  final int itemNum;
  final Function onTap;
  final Function onSecondaryTap;
  final Function onLongPress;

  ConnectionWidgetTile({
    @required this.index,
    @required this.fileInfos,
    @required this.isLoading,
    @required this.isListView,
    @required this.itemNum,
    @required this.onTap,
    @required this.onSecondaryTap,
    @required this.onLongPress,
  });

  @override
  _ConnectionWidgetTileState createState() => _ConnectionWidgetTileState();
}

class _ConnectionWidgetTileState extends State<ConnectionWidgetTile> {
  @override
  Widget build(BuildContext context) {
    return widget.fileInfos.length > 0 && !widget.isLoading
        ? widget.isListView
            ? Padding(
                padding: EdgeInsets.only(bottom: widget.itemNum != null ? widget.index == widget.itemNum - 1 ? 80.0 : .0 : .0),
                child: ListTile(
                  leading: widget.fileInfos[widget.index]["isDirectory"] == "true" ? Icon(Icons.folder_open) : Icon(Icons.insert_drive_file),
                  title: Text(widget.fileInfos[widget.index]["filename"]),
                  trailing: widget.fileInfos[widget.index]["isDirectory"] == "true"
                      ? CustomIconButton(icon: Icon(Icons.more_vert), onPressed: widget.onSecondaryTap)
                      : null,
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                ),
              )
            : Container(
                margin: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, .07),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6.0),
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Icon(
                              widget.fileInfos[widget.index]["isDirectory"] == "true" ? Icons.folder_open : Icons.insert_drive_file,
                              size: 32.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.fileInfos[widget.index]["filename"],
                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.4),
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            widget.fileInfos[widget.index]["isDirectory"] == "true"
                                ? CustomIconButton(
                                    icon: Icon(Icons.more_vert, size: 22.0),
                                    size: 26.0,
                                    onPressed: widget.onSecondaryTap,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
        : widget.index == 0
            ? Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : Container();
  }
}
