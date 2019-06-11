
import 'Classe.dart';
import 'Enseignant.dart';
import 'Matiere.dart';

class Cours {
  int id;
  int heureDebut;
  int heureFin;
  int matiereOrigin;
  int enseignantOrign;
  Matiere matiere;
  Enseignant enseignant;
  Classe classe;
  bool isAbsent;

  Cours({this.id = null, this.heureDebut, this.heureFin,this.matiere,this.enseignant, 
        this.classe, this.isAbsent = false, this.matiereOrigin, this.enseignantOrign});

  factory Cours.fromJson(Map<String, dynamic> json) {
      return Cours(
        id: json['id'],
        heureDebut: json['heure_debut'],
        heureFin: json['heure_fin'],
        isAbsent: json['isAbsent'],
        matiere: Matiere.fromJson(json['matiere']),
        enseignant: Enseignant.fromJson(json['enseignant']),
        classe: Classe.fromJson(json['classe']),
        matiereOrigin: json['matiereOrigin'],
        enseignantOrign: json['enseignantOrigin']
      );
    }  
}
