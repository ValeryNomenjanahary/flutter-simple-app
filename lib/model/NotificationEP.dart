class NotificationEP{
  String classe;
  String parcours;
  String message;
  String enseignant;
  String titre;

  NotificationEP({this.classe,this.parcours,this.message, this.enseignant, this.titre});

  factory NotificationEP.fromJson(Map<String, dynamic> json) {
    if(json != null){
        return NotificationEP(
          classe: json['classe'],
          parcours: json['parcours'],
          titre:  json['titre'],
          message: json['message'],
          enseignant: json['enseignant']
        );
      }  else 
      return null; 
    } 
}