import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:planets/utils/uidata.dart';
import 'package:planets/model/Matiere.dart';
import 'package:planets/model/Enseignant.dart';

class CoursService {
  String token;
  Object header;
  CoursService(String t){
    this.token  = t;
    this.header = {"Authorization": 'Token ' + this.token};
  }

  getCours(String classe, String parcours, String jour) async {
    return http
        .get(UIData.api_root + "creneaux_filter/$classe/$jour/$parcours");
  }

   removeCours(int id){
    return http.patch(UIData.api_root + "creneaux/$id/", body:
      {
        "id": "$id",
        "matiere": "",
        "enseignant": "",
        "isRemoveCours":"true"
      }, headers: this.header);
  }

   prendreCreneau(int id, int matiere, int enseignant, {bool isRemplacement:false}){
    return http.patch(UIData.api_root + "creneaux/$id/", body: 
      {
        "id": "$id",
        "matiere": "$matiere",
        "enseignant": "$enseignant",
        "isRemplacement": "$isRemplacement",
        "isAbsent":"false"
      }, headers: this.header);
  }

   markAbsent(int id){
    return http.patch(UIData.api_root + "creneaux/$id/", body: {"id":"$id","isAbsent": "true", "isSignalerAbsence":"true"}, headers: this.header);
  }  
}
