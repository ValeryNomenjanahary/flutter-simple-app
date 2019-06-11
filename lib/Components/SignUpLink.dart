import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:planets/Routes.dart';
class SignUp extends StatelessWidget {
  SignUp();
  @override
  Widget build(BuildContext context) {
    return (new Padding(
        padding: const EdgeInsets.only(
          top: 100.0,
        ),
        child: new InkWell(
          onTap: () {
            logUser();
            Routes.navigateTo(context, '/home/false',
              transition: TransitionType.fadeIn);
          },
          child: new Text(
            "Consulter l'emploi du temps",
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: new TextStyle(
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                color: Colors.grey,
                fontSize: 15.0),
          ),
        )));
  }

  void logUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged', false);    
  }  
}
