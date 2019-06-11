import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:planets/model/NotificationEP.dart';
import 'package:planets/Components/NotificationRow.dart';
import 'package:planets/utils/uidata.dart';

class NotificationTab extends StatefulWidget {
  @override
  _NotificationTabState createState() => new _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<NotificationEP> _notifications;
  bool _isLoading = false;
  bool _isLogged;
  String _token;
  Object _header;

  @override
  initState() {
    super.initState();
    _notifications = new List<NotificationEP>();
    initUserData();
  }

  void initUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this._isLogged = prefs.getBool('is_logged');
    });
    if (this._isLogged) {
      setState(() {
        _token = prefs.getString('token');
        _header = {"Authorization": 'Token ' + _token};
      });
      _loadNotifications();
    } else {
      setState(() {
        _header = {"": ""};
      });
      _loadNotifications();
    }
  }

  _loadNotifications() {
    setState(() {
      _isLoading = true;
    });
    http
        .get(UIData.api_root + "notifications/", headers: _header)
        .then((response) {
      if (response.statusCode == 200) {
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        final parsed = responseJson.cast<Map<String, dynamic>>();
        setState(() {
          _notifications = parsed
              .map<NotificationEP>((json) => NotificationEP.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        UIData.showServerInternalError();
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      UIData.showServerConnexionError();
    });
  }

  Widget _buildNotifications() {
    return new ListView.builder(
        //padding: const EdgeInsets.all(16.0),
        itemCount: _notifications.length,
        itemBuilder: (_, i) {
          return _buildRow(_notifications[i]);
        });
  }

  Widget _buildRow(NotificationEP n) {
    return new Dismissible(
        key: new ObjectKey(n),
        direction: DismissDirection.horizontal,
        onDismissed: (DismissDirection direction) {
          setState(() {
            _notifications.remove(n);
          });
          /*
          Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('1 conversation archived'),
              action: new SnackBarAction(
                  label: 'UNDO',
                  onPressed: () { handleUndo(item); }
              )
          ));
          */
        },
        child: new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: new Border(
                    bottom:
                        new BorderSide(color: Theme.of(context).dividerColor))),
            child: new ListTile(
                leading: new CircleAvatar(
                  backgroundColor: Colors.brown[800],
                  child: n.classe != null
                      ? new Icon(Icons.event, color: Colors.white)
                      : new Icon(Icons.person, color: Colors.white),
                  radius: 30.0,
                ),
                title: new Text(
                  n.titre,
                  style: new TextStyle(
                      fontSize: 19.0, fontWeight: FontWeight.w400),
                ),
                subtitle: n.classe != null
                    ? new Text(n.classe + " " + n.parcours + '\n\n${n.message}')
                    : new Text('${n.enseignant}\n\n${n.message}'),
                isThreeLine: true)));
  }

  @override
  Widget build(BuildContext context) {
    return new PageView(children: [
      _isLoading
          ? new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[new CircularProgressIndicator()],
            )
          : _notifications.length > 0
              ? new Column(
                  children: <Widget>[
                    new Expanded(child: _buildNotifications())
                  ],
                )
              : new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Icon(Icons.notifications_none,
                        size: 150.0, color: Colors.black12),
                    new Text('Aucune notification pour le moment')
                  ],
                )
    ]);
  }
}
