class Classe{
  int id;
  String libelleClasse;
  String parcours;
  String salle;

  Classe({this.id, this.libelleClasse, this.parcours, this.salle});

  factory Classe.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Classe(
        id: json['id'],
        libelleClasse: json['libelle_classe'],
        parcours: json['parcours'],
        salle: json['salle']
      );
    } else 
      return null;   
  }
}