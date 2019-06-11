import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:planets/model/Cours.dart';
import 'package:planets/logic/services/CoursService.dart';
import 'package:planets/logic/services/EnseignantService.dart';
import 'package:planets/Components/List.dart';
import 'package:planets/utils/uidata.dart';
import 'package:planets/model/Matiere.dart';

class Journee extends StatefulWidget {
  String jourLabel;
  String classe;
  Journee({this.jourLabel, this.classe});

  @override
  JourneeState createState() => new JourneeState();
}

class JourneeState extends State<Journee> {
  //variable
  List<Cours> _cours = null;
  List<Matiere> _matieres = null;
  List _classe = ["L1", "L2", "L3", "M1", "M2"];
  List _parcours = ["GB", "SR", "IG"];
  List<DropdownMenuItem<String>> _dropDownMenuClasses;
  List<DropdownMenuItem<String>> _dropDownMenuParcours;
  List<DropdownMenuItem<String>> _dropDownMenuMatieres;
  String _currentClasse;
  String _currentParcours;
  bool _is_logged = false;
  int _currentHeureDebut;
  int _currentHeureFin;
  int _currentMatiere;
  int _enseignantId;
  int _currentCours;
  bool _isRemplacement = false;
  String _token;
  CoursService _coursService;
  bool _loading = false;
  //fin_variable

  @override
  void initState() {
    _dropDownMenuClasses = getDropDownMenuClasses();
    _dropDownMenuParcours = getDropDownMenuParcours();

    _currentParcours = _dropDownMenuParcours[0].value;
    _currentClasse = _dropDownMenuClasses[0].value;
    super.initState();
    this.initUserData();
  }

  void loadCours() {
    if (mounted) {
      setState(() {
        _loading = true;
      });
      _coursService
          .getCours(_currentClasse, _currentParcours, widget.jourLabel)
          .then((response) {
        if (response.statusCode == 200) {
          var responseJson = json.decode(utf8.decode(response.bodyBytes));
          final parsed = responseJson.cast<Map<String, dynamic>>();
          setState(() {
            _cours = new List<Cours>();
            _cours = parsed.map<Cours>((json) => Cours.fromJson(json)).toList();
          });
        } else {
          showServerInternalError();
        }
      }).catchError((error) {
        setState(() {
          _cours = null;
        });
        showServerConnexionError();
      }).whenComplete(() {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  void initUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this._is_logged = prefs.getBool('is_logged');
    });
    if (this._is_logged) {
      setState(() {
        _enseignantId = prefs.getInt('enseignantId');
        _token = prefs.getString('token');
        _coursService = new CoursService(_token);
      });
      loadCours();
      new EnseignantService(_token).getMatiere(_enseignantId).then((response) {
        if (response.statusCode == 200) {
          var responseJson = json.decode(utf8.decode(response.bodyBytes));
          final parsed = responseJson.cast<Map<String, dynamic>>();
          setState(() {
            _matieres = new List<Matiere>();
            _matieres =
                parsed.map<Matiere>((json) => Matiere.fromJson(json)).toList();
            _dropDownMenuMatieres = getDropDownMenuMatieres();
            _currentMatiere = _matieres[0].id;
          });
        } else {
          showServerInternalError();
        }
      }).catchError((error) {
        showServerConnexionError();
      });
    } else {
      _coursService = new CoursService("");
      loadCours();
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuClasses() {
    List<DropdownMenuItem<String>> items = new List();
    for (String classe in _classe) {
      items.add(new DropdownMenuItem(value: classe, child: new Text(classe)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropDownMenuParcours() {
    List<DropdownMenuItem<String>> items = new List();
    for (String p in _parcours) {
      items.add(new DropdownMenuItem(value: p, child: new Text(p)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getDropDownMenuMatieres() {
    List<DropdownMenuItem<String>> items = new List();
    for (Matiere m in _matieres) {
      items.add(new DropdownMenuItem(
          value: m.id.toString(), child: new Text(m.libelleMatiere)));
    }
    return items;
  }

  void changedDropDownClasse(String selectedClasse) {
    setState(() {
      _currentClasse = selectedClasse;
    });
    loadCours();
  }

  void changedDropDownParcours(String selectedParcours) {
    setState(() {
      _currentParcours = selectedParcours;
    });
    loadCours();
  }

  void changedDropDownMatiere(String selectedMatiere) {
    setState(() {
      _currentMatiere = int.parse(selectedMatiere);
    });
    Navigator.of(context).pop();
    showFormDialog(
        _currentHeureDebut, _currentHeureFin, _currentCours, _isRemplacement);
  }

  Widget _buildCours() {
    return new ListView.builder(
        //padding: const EdgeInsets.all(16.0),
        itemCount: _cours.length,
        itemBuilder: (_, i) {
          return _buildRow(_cours[i]);
        });
  }

  Widget _buildRow(Cours cours) {
    if (_is_logged) {
      if (cours.matiere != null) {
        //Misy cours
        if (cours.matiereOrigin != null) {
          // misy enseignant propriétaire absent
          if ((_matieres
                  .where((m) => m.id == cours.matiere.id)
                  .toList()
                  .length >
              0)) {
            //cours rattrapagnlé enseignant connécté
            return new ListData(
              margin: EdgeInsets.all(0.0),
              heure:
                  cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
              subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
              title: cours.matiere.libelleMatiere,
              rappelMsg: "(Votre cours de rattrapage)",
              width: 100.0,
              type: UIData.onlyRemove,
              redBorder: cours.isAbsent,
              onIconRemovePressed: () {
                removeCours(cours.id);
              },
            );
          } else {
            // tsy cours rattrapagenlé enseignant connecté
            return new ListData(
              margin: EdgeInsets.all(0.0),
              heure:
                  cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
              subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
              title: cours.matiere.libelleMatiere,
              width: 100.0,
              type: UIData.onlyView,
              redBorder: cours.isAbsent,
            );
          }
        } else {
          // tsy absent le enseignant propriétaire
          if ((_matieres
                  .where((m) => m.id == cours.matiere.id)
                  .toList()
                  .length >
              0)) {
            // propriétaire anle cours lé enseignant connecté
            return new ListData(
              margin: EdgeInsets.all(0.0),
              heure:
                  cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
              subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
              title: cours.matiere.libelleMatiere,
              width: 100.0,
              type: UIData.ownerMatiere,
              redBorder: cours.isAbsent,
              onIconEventBusyPressed: () {
                markAbsent(cours.id);
              },
              onIconRemovePressed: () {
                removeCours(cours.id);
              },
            );
          } else {
            // tsy propriétaire anle cours le enseignant connecté
            if (cours.isAbsent) {
              //absent le prof
              return new ListData(
                margin: EdgeInsets.all(0.0),
                heure: cours.heureDebut.toString() +
                    "-" +
                    cours.heureFin.toString(),
                subtitle: "",
                title: "",
                rappelMsg: "Enseignant absent",
                width: 100.0,
                redBorder: cours.isAbsent,
                type: UIData.crenauLibre,
                onIconBookPressed: () => showFormDialog(
                    cours.heureDebut, cours.heureFin, cours.id, true),
              );
            } else {
              // présent le prof
              return new ListData(
                margin: EdgeInsets.all(0.0),
                heure: cours.heureDebut.toString() +
                    "-" +
                    cours.heureFin.toString(),
                redBorder: cours.isAbsent,
                subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
                title: cours.matiere.libelleMatiere,
                width: 100.0,
                type: UIData.onlyView,
              );
            }
          }
        }
      } else {
        // tsisy matiere le hora
        return new ListData(
          margin: EdgeInsets.all(0.0),
          heure: cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
          subtitle: "",
          title: "",
          width: 100.0,
          redBorder: cours.isAbsent,
          type: UIData.crenauLibre,
          onIconBookPressed: () =>
              showFormDialog(cours.heureDebut, cours.heureFin, cours.id, false),
        );
      }
    } else {
      if (cours.matiere == null) {
        return new ListData(
          margin: EdgeInsets.all(0.0),
          heure: cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
          subtitle: "",
          title: "",
          width: 100.0,
          redBorder: cours.isAbsent,
          type: UIData.onlyView,
        );
      } else {
        if (cours.matiereOrigin != null) {
          // misy prof naka le heure absence
          return new ListData(
            margin: EdgeInsets.all(0.0),
            heure:
                cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
            redBorder: cours.isAbsent,
            subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
            title: cours.matiere.libelleMatiere,
            rappelMsg: " (Cours de rattrapage)",
            width: 100.0,
            type: UIData.onlyView,
          );
        } else {
          if (cours.isAbsent) {
            return new ListData(
              margin: EdgeInsets.all(0.0),
              heure:
                  cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
              subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
              title: cours.matiere.libelleMatiere,
              rappelMsg: "Cours annulé pour aujourdhui",
              width: 100.0,
              redBorder: cours.isAbsent,
              type: UIData.onlyView,
            );
          } else {
            return new ListData(
              margin: EdgeInsets.all(0.0),
              heure:
                  cours.heureDebut.toString() + "-" + cours.heureFin.toString(),
              redBorder: cours.isAbsent,
              subtitle: cours.classe.salle + ", " + cours.enseignant.nom,
              title: cours.matiere.libelleMatiere,
              width: 100.0,
              type: UIData.onlyView,
            );
          }
        }
      }
    }
  }

  Future<Null> showFormDialog(
      int heureDebut, int heureFin, int coursId, bool isRemplacement) async {
    setState(() {
      _currentHeureDebut = heureDebut;
      _currentHeureFin = heureFin;
      _currentCours = coursId;
      _isRemplacement = isRemplacement;
    });
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showForm(),
                    SizedBox(
                      height: 10.0,
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ));
  }

  showForm() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Material(
          clipBehavior: Clip.antiAlias,
          elevation: 2.0,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ListTile(
                  title: Text("Classe"),
                  subtitle: Text(_currentClasse),
                  trailing: Text(_currentHeureDebut.toString() +
                      "-" +
                      _currentHeureFin.toString()),
                ),
                ListTile(
                  title: Text("Parcours"),
                  subtitle: Text(_currentParcours),
                ),
                ListTile(
                  title: Text("Matière"),
                  subtitle: new DropdownButton(
                    value: _currentMatiere.toString(),
                    items: _dropDownMenuMatieres,
                    onChanged: changedDropDownMatiere,
                  ),
                ),
                RaisedButton(
                  child: Text("Prendre ce créneau"),
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    _coursService
                        .prendreCreneau(
                            _currentCours, _currentMatiere, _enseignantId,
                            isRemplacement: _isRemplacement)
                        .then((response) {
                      if (response.statusCode == 200) {
                        if (_isRemplacement)
                          showSucces(
                              "L'horaire de l'enseignant absent vous a été accordé.");
                        else
                          showSucces("Créneau horaire réservé");
                      }
                    }).catchError((error) {
                      showServerConnexionError();
                    }).whenComplete(() {
                      setState(() {
                        Navigator.of(context, rootNavigator: true).pop();
                        _loading = false;
                      });
                      loadCours();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildWidget() {
    return new PageView(children: [
      _cours != null
          ? new Column(children: [
              new Center(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: new EdgeInsets.all(16.0),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new DropdownButton(
                          value: _currentClasse,
                          items: _dropDownMenuClasses,
                          onChanged: changedDropDownClasse,
                        ),
                        new DropdownButton(
                          value: _currentParcours,
                          items: _dropDownMenuParcours,
                          onChanged: changedDropDownParcours,
                        )
                      ],
                    )
                  ],
                ),
              ),
              new Expanded(
                child: _buildCours(),
              ),
            ])
          : _loading
              ? new CircularProgressIndicator(
                  value: null,
                  strokeWidth: 1.0,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new RaisedButton(
                        child: Text("Réessayer la connexion au serveur"),
                        onPressed: () {
                          setState(() {
                            loadCours();
                          });
                        })
                  ],
                )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //App Bar
      appBar: new AppBar(
        title: new Text(widget.jourLabel),
        elevation: 2.0,
      ),

      body: ModalProgressHUD(child: _buildWidget(), inAsyncCall: _loading),
    );
  }

  //util
  showServerInternalError() {
    Fluttertoast.showToast(
        msg: UIData.serveur_error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  showServerConnexionError() {
    Fluttertoast.showToast(
        msg: UIData.connexion_error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  showSucces(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.brown[800],
        textColor: Colors.white);
  }

  removeCours(int id) {
    setState(() {
      _loading = true;
    });
    _coursService.removeCours(id).then((response) {
      if (response.statusCode == 200) {
        showSucces("Cours supprimé");
        loadCours();
      } else
        showServerInternalError();
    }).catchError((error) {
      showServerConnexionError();
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  markAbsent(int id) {
    setState(() {
      _loading = true;
    });
    _coursService.markAbsent(id).then((response) {
      if (response.statusCode == 200) {
        showSucces("Absence envoyée");
        loadCours();
      } else
        showServerInternalError();
    }).catchError((error) {
      showServerConnexionError();
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }
}
