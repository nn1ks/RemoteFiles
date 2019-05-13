import 'package:flutter/material.dart';

class ConnectionWidgetTile extends StatefulWidget {
  final int index;
  final List<Map<String, String>> fileInfos;
  final bool isLoading;
  final bool isListView;
  final int itemNum;
  final Function onTap;
  final Function onLongPress;

  ConnectionWidgetTile({
    @required this.index,
    @required this.fileInfos,
    @required this.isLoading,
    @required this.isListView,
    @required this.itemNum,
    @required this.onTap,
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
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                ),
              )
            : Container(
                margin: EdgeInsets.all(6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4.0),
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 4.0),
                          Icon(
                            widget.fileInfos[widget.index]["isDirectory"] == "true" ? Icons.folder_open : Icons.insert_drive_file,
                            size: 32.0,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            widget.fileInfos[widget.index]["filename"],
                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.4),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
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
