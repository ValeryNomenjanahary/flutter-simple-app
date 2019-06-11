import 'package:flutter/material.dart';

import 'package:planets/utils/uidata.dart';

class ListData extends StatelessWidget {
  final EdgeInsets margin;
  final double width;
  final String title;
  final String subtitle;
  final String rappelMsg;
  final String heure;
  final VoidCallback onIconBookPressed;
  final VoidCallback onIconEventBusyPressed;
  final VoidCallback onIconRemovePressed;
  final int type;
  final bool redBorder;
  ListData(
      {this.margin,
      this.subtitle,
      this.title,
      this.width,
      this.rappelMsg = "",
      this.heure = "",
      this.onIconBookPressed = null,
      this.onIconEventBusyPressed = null,
      this.onIconRemovePressed = null,
      this.type,
      this.redBorder = false});
  @override
  Widget build(BuildContext context) {
    return (new Container(
      alignment: Alignment.center,
      margin: margin,
      width: width,
      decoration: new BoxDecoration(
          color: Colors.white,
          border: new Border(
            top: new BorderSide(
                width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
            bottom: new BorderSide(
                width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
          )),
      child: new Row(
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            margin: new EdgeInsets.only(
                left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
            width: 60.0,
            height: 60.0,
            child: new Text(
              this.heure,
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
            ),
          ),
          new Expanded(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                new Text(
                  title,
                  style: new TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
                new Text(
                rappelMsg,
                  style: new TextStyle(
                      color: Colors.amberAccent[400],
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400),
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 5.0),
                  child: new Text(
                    subtitle,
                    style: new TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300),
                  ),
                )
              ])),
          this.type == UIData.crenauLibre
              ? IconButton(
                  icon: Icon(Icons.bookmark_border),
                  tooltip: 'Réserver ce créneau horaire',
                  onPressed: onIconBookPressed,
                )
              : this.type == UIData.ownerMatiere
                  ? Row(children: [
                      IconButton(
                        icon: Icon(Icons.event_busy),
                        tooltip: 'Signaler une absence',
                        onPressed: onIconEventBusyPressed,
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        tooltip: 'Supprimer',
                        onPressed: onIconRemovePressed,
                      )
                    ])
                  : this.type == UIData.onlyRemove
                      ? Row(children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            tooltip: 'Supprimer',
                            onPressed: onIconRemovePressed,
                          )
                        ])
                      : Text("")
        ],
      ),
    ));
  }
}
