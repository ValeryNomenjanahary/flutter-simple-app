import 'dart:async';

import 'package:planets/logic/viewmodel/jour_view_model.dart';
import 'package:planets/model/Jour.dart';

class JourBloc {
  final _jourVM = JourViewModel();
  final jourController = StreamController<List<Jour>>();

  Stream<List<Jour>> get jours => jourController.stream;

  JourBloc() {
    jourController.add(_jourVM.getJours());
  }
}
