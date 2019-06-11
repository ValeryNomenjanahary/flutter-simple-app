import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:planets/ui/page/Journee.dart';
import "package:planets/Tabs/Tabs.dart";
import 'package:planets/ui/page/Login/index.dart';

class Routes {
  static final Router _router = new Router();

    static var indexHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new LoginScreen();
    });  
    
    //horaire jour
    static var journeeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new Journee(jourLabel:params["jour"][0], classe: params["classe"][0]);
    });  
    
    //
    static var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      bool isLogged = params["isLogged"][0].toLowerCase() == 'true';
      if(params.containsKey("selectedTab"))
          return new Tabs(isLogged:isLogged, selectedTab:int.parse(params["selectedTab"][0]));
      return new Tabs(isLogged:isLogged);
    });

  static void initRoutes() {
    _router.define("/journee/:classe/:jour", handler: journeeHandler);
    _router.define("/home/:isLogged", handler: homeHandler);    
    _router.define("/home/:isLogged/:selectedTab", handler: homeHandler);
    _router.define("/", handler: indexHandler);    
  }

  static void navigateTo(context, String route, {TransitionType transition}) {
    _router.navigateTo(context, route, transition: transition);
  }
  

}