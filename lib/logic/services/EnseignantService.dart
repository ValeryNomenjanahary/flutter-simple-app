import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:planets/utils/uidata.dart';
import 'package:planets/model/Cours.dart';

class EnseignantService {

  String token;
  Object header;

  EnseignantService(String t){
    this.token = t;
    this.header = {"Authorization": 'Token ' + this.token};
  }

  getMatiere(int enseignantId) async {

    return http
        .get(UIData.api_root + "matiere_filter/$enseignantId/", headers: this.header);
  }  

  signalerAbsence(int enseignantId, String dateDebut, String dateFin) async {

    return http
        .patch(UIData.api_root + "enseignant/$enseignantId/", 
		          body: {
                "id":"$enseignantId",
                "date_debutAbsence":"$dateDebut",
                "date_finAbsence":"$dateFin",
                "isSignalerAbsence": "true"
              },
		          headers: this.header);
  }   
}