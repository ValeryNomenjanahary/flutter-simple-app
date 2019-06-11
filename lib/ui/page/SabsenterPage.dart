import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluro/fluro.dart';

import 'package:planets/logic/services/EnseignantService.dart';
import 'package:planets/utils/uidata.dart';
import 'package:planets/Routes.dart';

class SabsenterPage extends StatefulWidget {
  @override
  _SabsenterPageState createState() => _SabsenterPageState();
}

class _SabsenterPageState extends State<SabsenterPage> {
  String _dateDebut;
  String _dateFin;
  String _token;
  int _enseignantId;
  List<DateTime> _picked;
  DateTime _storedDateDebut;
  DateTime _storedDateFin;
  DateTime _now = new DateTime.now();

  bool _haveSelected;
  bool _saving;
  bool _isDejaAbsent;

  EnseignantService _enseignantService;

  @override
  void initState() {
    _dateDebut = "";
    _dateFin = "";
    _saving = false;
    _isDejaAbsent = false;
    _haveSelected = false;

    super.initState();
    this.initUserData();

  }

  void initUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this._token = prefs.getString('token');
      this._enseignantService = new EnseignantService(_token);
      this._enseignantId = prefs.getInt('enseignantId');
      if(prefs.getString('date_debutAbsence') != null){
          _storedDateDebut = DateTime.parse(prefs.getString('date_debutAbsence'));
          _storedDateFin = DateTime.parse(prefs.getString('date_finAbsence'));
      } else {
          _storedDateDebut = null;
          _storedDateFin = null;
      }
    });
          if (_storedDateDebut == null) {
            _showDatePicker(context);
          } else {
            var formatter = new DateFormat('dd-MM-yyyy');

            setState(() {
              _isDejaAbsent = true;
              _haveSelected = true;
              _dateDebut = formatter.format(_storedDateDebut);
              _dateFin = formatter.format(_storedDateFin);
            });
          }    
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        //App Bar
        appBar: new AppBar(
          title: new Text(
            "S'absenter",
            style: new TextStyle(
              fontSize: 20.0,
            ),
          ),
          elevation: 4.0,
        ),

        //Content of tabs
        body: ModalProgressHUD(
            child: new PageView(
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _haveSelected
                        ? new Card(
                            child: new Column(children: <Widget>[
                            _isDejaAbsent
                                ?                             new ListTile(
                              title: Text("Vous avez déjà marquez que vous seriez absent"),
                            )
                                :                             new ListTile(
                              title: Text("Vous serez absent"),
                            ),
                            new ListTile(
                              title: Text("Du"),
                              subtitle: Text(_dateDebut),
                            ),
                            new ListTile(
                              title: Text("Au"),
                              subtitle: Text(_dateFin),
                            ),
                            _isDejaAbsent
                                ? new Text("")
                                :
                            RaisedButton(
                              child: Text("Valider"),
                              onPressed: () {
                                _sendAbsence();
                              },
                            )
                          ]))
                        : RaisedButton(
                            child: Text(
                                "Séléctionner l'intervalle de date d'absence"),
                            onPressed: () {
                              _showDatePicker(context);
                            },
                          )
                  ],
                )
              ],
            ),
            inAsyncCall: _saving),
      );

  _showDatePicker(context) async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: _now,
        initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2020));
    if (picked != null && picked.length == 2) {
      DateTime temp = new DateTime(_now.year,_now.month, _now.day,0,0,0,0,0);            
      if (picked[0].compareTo(temp) >= 0) {
        var formatter = new DateFormat('dd-MM-yyyy');
        setState(() {
          _haveSelected = true;
          _dateDebut = formatter.format(picked[0]);
          _dateFin = formatter.format(picked[1]);
          _picked = picked;
        });
      }
	else {
	      _showDaterror("La date de début d'absence doit être supérieur ou égale à la date d'aujourdhui");
    	}      
    } else {
        _showDaterror("Merci de séléctionner la date de début et fin de votre absence.");
    }
  }

  _sendAbsence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var formatter = new DateFormat('yyyy-MM-dd');
    String debut = formatter.format(_picked[0]);
    String fin = formatter.format(_picked[1]);
    setState(() {
      _saving = true;
    });
    this
        ._enseignantService
        .signalerAbsence(_enseignantId, debut, fin)
        .then((response) {
      if (response.statusCode == 200) {
        prefs.setString('date_debutAbsence', debut);
        prefs.setString('date_finAbsence', fin);        
        Routes.navigateTo(context, '/home/true',
            transition: TransitionType.fadeIn);
        UIData.showSucces("Absence publiée");
      }
    }).catchError((error) {
      UIData.showServerConnexionError();
    }).whenComplete(() {
      setState(() {
        _saving = false;
      });
    });
  }

  Future<void> _showDaterror(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dates incorrectes'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
