import 'package:flutter/material.dart';

class NotificationRow extends StatelessWidget {
  String message;
  String classe;
  String parcours;
  String enseignant;

  NotificationRow(
      {this.message = "",
      this.classe = "",
      this.parcours = "",
      this.enseignant = ""});

  @override
  Widget build(BuildContext context) {
    return (new Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 2.0, bottom: 2.0),
      width: 100.0,
      decoration: new BoxDecoration(
        color: Colors.white,
        border: new Border(
          top: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
          bottom: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
        ),
        shape: BoxShape.rectangle,
        boxShadow: <BoxShadow>[
          new BoxShadow(
              color: Colors.white,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0))
        ],
      ),
      child: new Row(
        children: <Widget>[
          new Container(
              alignment: Alignment.center,
              margin: new EdgeInsets.only(
                  left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
              width: 60.0,
              height: 60.0,
              child: classe != null
                  ? new Text(
                      this.classe + " " + this.parcours,
                      style: new TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w400),
                    )
                  : new Text(
                      enseignant,
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w400),
                    )),
          new Expanded(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                new Row(children: [
                  new Flexible(
                      child: new Container(
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                          child: new Text(
                            this.message,
                            softWrap: true,
                            style: new TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w400),
                          )))
                ]),
              ])),
        ],
      ),
    ));
  }
}
