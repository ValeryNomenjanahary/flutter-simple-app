import "package:flutter/material.dart";
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:fluro/fluro.dart';
import 'dart:async';

import "./EmploiDuTempsTab.dart";
import './NotificationTab.dart';
import "package:planets/utils/uidata.dart";
import 'package:planets/Routes.dart';

class Tabs extends StatefulWidget {
  final bool isLogged;
  final int selectedTab;
  Tabs({this.isLogged, this.selectedTab = 0});

  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tab = 0;
  String _title_app = null;
  bool _is_logged = null;
  String _token;
  String _nom;

  @override
  void initState() {
    initUserData();
    super.initState();
    _tab = widget.selectedTab;
    _is_logged = widget.isLogged;
    _tabController = new TabController(vsync: this, length: 4);
    _tabController.addListener(_onTabChanged);
    _tabController.animateTo(_tab);
    this._title_app = "Emploi du temps";
  }

  void initUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _nom = prefs.getString('nom');
    });
  }

  void clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear().then((res) {
      Routes.navigateTo(context, '/', transition: TransitionType.fadeIn);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _is_logged
        ? new Scaffold(
            appBar: new AppBar(
              title: new Text(_title_app),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                Builder(
                  builder: (context) => IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
                ),
              ],
            ),
            bottomNavigationBar: new Material(
                color: Colors.brown[800],
                child: new TabBar(controller: _tabController, tabs: <Tab>[
                  new Tab(icon: new Icon(Icons.event_note, size: 30.0)),
                  new Tab(icon: new Icon(Icons.notifications, size: 30.0)),
                ])),
            body: new TabBarView(controller: _tabController, children: <Widget>[
              new EmploiDuTempsTab(),
              new NotificationTab()
            ]),
            //Drawer
            endDrawer: new SizedBox(
                width: 190.0,
                child: new Drawer(
                    child: new ListView(
                  children: <Widget>[
                    new Container(
                      height: 120.0,
                      child: DrawerHeader(
                          child: new CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/img/user.png')),
                          decoration: BoxDecoration(color: Colors.brown[800]),
                          margin: EdgeInsets.all(0.0),
                          padding: EdgeInsets.all(0.0)),
                    ),
                    new ListTile(title: new Text("Bonjour $_nom")),
                    new Divider(color: Colors.brown),
                    new ListTile(
                        leading: new Icon(Icons.info),
                        title: new Text("S'absenter"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/sabsenter');
                        }),
                    new ListTile(
                        leading: new Icon(Icons.exit_to_app),
                        title: new Text('Se déconnecter'),
                        onTap: () {
                          UIData.getDeviceDetails().then((deviceInfo) {
                            String identifier = deviceInfo[2];
                            http.post(UIData.api_root + "logout/", body: {
                              "dev_id": "$identifier"
                            }, headers: {
                              "Authorization": 'Token ' + _token
                            }).then((response) async {
                              if (response.statusCode == 200) {
                                clearUserData();
                              } else {
                                Fluttertoast.showToast(
                                    msg: UIData.serveur_error,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIos: 1,
                                    backgroundColor: Colors.brown[800],
                                    textColor: Colors.white);
                              }
                            }).catchError((error) {
                              Fluttertoast.showToast(
                                  msg: UIData.connexion_error,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIos: 1,
                                  backgroundColor: Colors.brown[800],
                                  textColor: Colors.white);
                            });
                          });
                        }),
                  ],
                ))),
          )
        : new Scaffold(
            appBar: new AppBar(
              title: new Text(_title_app),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            bottomNavigationBar: new Material(
                color: Colors.brown[800],
                child: new TabBar(controller: _tabController, tabs: <Tab>[
                  new Tab(icon: new Icon(Icons.event_note, size: 30.0)),
                  new Tab(icon: new Icon(Icons.notifications, size: 30.0)),
                ])),
            body: new TabBarView(controller: _tabController, children: <Widget>[
              new EmploiDuTempsTab(),
              new NotificationTab()
            ]),
          );
  }

  void _onTabChanged() {
    setState(() {
      this._tab = _tabController.index;
    });

    switch (_tab) {
      case 0:
        this._title_app = "Emploi du temps";
        break;

      case 1:
        this._title_app = "Notifications";
        break;
    }
  }
}
