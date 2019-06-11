class Enseignant{
  int id;
  String nom;

  Enseignant({this.id, this.nom});

  factory Enseignant.fromJson(Map<String, dynamic> json) {
    if(json != null){
      return Enseignant(
        id: json['id'],
        nom: json['nom']
      );
    } else {
      return null;
    }  
  }
}