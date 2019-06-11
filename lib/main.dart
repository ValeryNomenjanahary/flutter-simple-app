import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:planets/Routes.dart';
import 'package:planets/ui/page/Login/index.dart';
import "package:planets/Tabs/Tabs.dart";
import 'package:planets/ui/page/SabsenterPage.dart';
import 'package:planets/utils/uidata.dart';

void main() {
  Routes.initRoutes();
  runApp(new MaterialApp(
    title: UIData.appName,
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(
        primarySwatch: Colors.brown,
        cursorColor: Colors.brown[600],    
        accentColor: Colors.brown[600],
        fontFamily: UIData.quickFont,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.brown[600],
        backgroundColor: Colors.white),
    initialRoute: '/',
    routes: {
      '/': (context) => LoginScreen()
    },
    onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case '/sabsenter':
          return new FromRightToLeft(
            builder: (_) => new SabsenterPage(),
            settings: settings,
          );
      }
    },
    localizationsDelegates: [
      // ... app-specific localization delegate[s] here
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('fr', 'FR'),
    ],
  ));
}

class FromRightToLeft<T> extends MaterialPageRoute<T> {
  FromRightToLeft({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;

    return new SlideTransition(
      child: new Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.black26,
            blurRadius: 25.0,
          )
        ]),
        child: child,
      ),
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(new CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 800);
}
