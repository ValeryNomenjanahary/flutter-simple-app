import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluro/fluro.dart';

import 'styles.dart';
import 'loginAnimation.dart';
import 'package:planets/Components/WhiteTick.dart';
import 'package:planets/Components/InputFields.dart';
import 'package:planets/Components/SignInButton.dart';
import 'package:planets/Components/SignUpLink.dart';
import 'package:planets/utils/uidata.dart';
import 'package:planets/Routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  var animationStatus = 0;
  final _formKey = GlobalKey<FormState>();
  final _identifiantCtrl = TextEditingController();
  final _paswdCtrl = TextEditingController();
  bool _isLogged;
  String _regId;
  String _messageBody;
  String _messageTitle;
  Object _header;
  String _token;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  var flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _isLogged = false;

    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var a = message['data'];
        setState(() {
          _messageBody = a['body'];
          _messageTitle = a['title'];
        });
        _showNotification();
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _firebaseMessaging.getToken().then((String token) {
      setState(() {
        _regId = token;
      });
      _registerDevice();
    });

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    _identifiantCtrl.dispose();
    _paswdCtrl.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await _loginButtonController.forward();
      await _loginButtonController.reverse();
    } on TickerCanceled {}
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text('Etes vous sûr de vouloir quitter?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Non'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                child: new Text('Oui'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return (new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          body: new Container(
              child: new Container(
                  decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                    colors: <Color>[
                      const Color.fromRGBO(255, 255, 255, 0.8),
                      const Color.fromRGBO(255, 255, 255, 0.9),
                    ],
                    stops: [0.2, 1.0],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0),
                  )),
                  child: new ListView(
                    padding: const EdgeInsets.all(0.0),
                    children: <Widget>[
                      new Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Padding(
                                  padding: const EdgeInsets.only(
                                      top: 100.0, bottom: 40.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Tick(image: tick),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      Text(
                                        "ENI Planning",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.brown),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "Se connecter en tant qu'enseignant",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )),
                              new Container(
                                margin:
                                    new EdgeInsets.symmetric(horizontal: 20.0),
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Form(
                                        key: _formKey,
                                        child: new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            new InputFieldArea(
                                              hint: "Identifiant",
                                              obscure: false,
                                              icon: Icons.person_outline,
                                              controller: _identifiantCtrl,
                                            ),
                                            new InputFieldArea(
                                              hint: "Mot de passe",
                                              obscure: true,
                                              icon: Icons.lock_outline,
                                              controller: _paswdCtrl,
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              new SignUp(),
                            ],
                          ),
                          animationStatus == 0
                              ? new Padding(
                                  padding: const EdgeInsets.only(bottom: 40.0),
                                  child: new InkWell(
                                      onTap: () {
                                        if (_formKey.currentState.validate()) {
                                          _loginAction();
                                        }
                                      },
                                      child: new SignIn()),
                                )
                              : new StaggerAnimation(
                                  buttonController:
                                      _loginButtonController.view),
                        ],
                      ),
                    ],
                  ))),
        )));
  }

  _loginAction() {
    String username = _identifiantCtrl.text;
    String password = _paswdCtrl.text;
    http.post(UIData.api_root + "login/", body: {
      "username": "$username",
      "password": "$password"
    }).then((response) async {
      if (response.statusCode == 200) {
        setState(() {
          animationStatus = 1;
          _isLogged = true;
          _token = json.decode(response.body)['token'];
        });
        _playAnimation();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged', true);
        await prefs.setString('nom', username);

        prefs.setInt('enseignantId', json.decode(response.body)['userId']);
        prefs.setString('token', json.decode(response.body)['token']);
        prefs.setString('date_debutAbsence', json.decode(response.body)['date_debutAbsence']);
        prefs.setString('date_finAbsence', json.decode(response.body)['date_finAbsence']);

        _registerDevice();
      } else {
        Fluttertoast.showToast(
            msg: UIData.login_error,
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
  }

  _registerDevice() async {
    if (_isLogged)
      _header = {"Authorization": 'Token ' + _token};
    else
      _header = {"": ""};
    UIData.getDeviceDetails().then((deviceInfo) {
      String deviceName = deviceInfo[0];
      String identifier = deviceInfo[2];
      http
          .post(UIData.api_root + "register-device/",
              body: {
                "dev_id": "$identifier",
                "reg_id": "$_regId",
                "name": "$deviceName"
              },
              headers: _header)
          .then((response) {});
    });
  }

  Future _showNotification() async {
    var bigTextStyleInformation = new BigTextStyleInformation(_messageBody,
        htmlFormatBigText: true,
        contentTitle: _messageTitle,
        htmlFormatContentTitle: true,
        summaryText: '<i>ENI Planning</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'ENI Planning channel notification id',
        'ENI Planning channel notification channel name',
        'ENI Planning channel notification channel description',
        style: AndroidNotificationStyle.BigText,
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, _messageTitle, _messageBody, platformChannelSpecifics);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Routes.navigateTo(context, '/home/$_isLogged/1',
        transition: TransitionType.fadeIn);
  }
}
