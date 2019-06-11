import 'dart:math';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UIData {
  //api root
  static const String api_root = "http://192.168.43.199:8000/";

  //message
  static const String serveur_error = "Erreur interne au serveur";
  static const String connexion_error = "Connexion au serveur impossible";
  static const String login_error =
      "Identifiant et/ou mot de passe incorrect(s)";
  //list data
  static const int crenauLibre = 1;
  static const int ownerMatiere = 2;
  static const int onlyView = 3;
  static const int onlyRemove = 4;

  //routes
  static const String homeRoute = "/home";

  //strings
  static const String appName = "Emploi du temps";

  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  //images
  static const String imageDir = "assets/images";
  static const String pkImage = "$imageDir/pk.jpg";

  //login
  static const String enter_code_label = "Phone Number";

  //gneric
  static const String error = "Error";

  static const MaterialColor ui_kit_color = Colors.grey;

//colors
  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [
    Colors.cyan.shade600,
    Colors.blue.shade900
  ];

  //randomcolor
  static final Random _random = new Random();

  /// Returns a random color.
  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }

  //util
  static showServerInternalError() {
    Fluttertoast.showToast(
        msg: UIData.serveur_error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  static showServerConnexionError() {
    Fluttertoast.showToast(
        msg: UIData.connexion_error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  static showSucces(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  static Future<List<String>> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId;

      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
    }

    return [deviceName, deviceVersion, identifier];
  }
}
