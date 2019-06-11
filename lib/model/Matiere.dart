class Matiere{
  int id;
  String libelleMatiere;
  int enseignantId;

  Matiere({this.id, this.libelleMatiere, this.enseignantId});

  factory Matiere.fromJson(Map<String, dynamic> json) {
    if(json != null){
        return Matiere(
          id: json['id'],
          libelleMatiere: json['libelle_matiere'],
          enseignantId: json['enseignant']
        );
      }  else 
      return null; 
    } 
}