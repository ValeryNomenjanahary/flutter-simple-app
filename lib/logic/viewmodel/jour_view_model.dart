import 'package:planets/model/Jour.dart';

class JourViewModel {
  List<Jour> jours;

  JourViewModel({this.jours});

  getJours() {
    return jours = <Jour>[
      Jour(label: "LUNDI"),
      Jour(label: "MARDI"),
      Jour(label: "MERCREDI"),
      Jour(label: "JEUDI"),
      Jour(label: "VENDREDI"),
      Jour(label: "SAMEDI"),    
    ];
  }
}
