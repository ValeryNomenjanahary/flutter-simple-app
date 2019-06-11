import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:planets/logic/bloc/jour_bloc.dart';
import 'package:planets/model/Jour.dart';
import 'package:planets/Routes.dart';

class JoursPage extends StatelessWidget {
  final _scaffoldState = GlobalKey<ScaffoldState>();
  Size deviceSize;
  BuildContext _context;
  //menuStack
  Widget jourStack(BuildContext context, Jour jour) => InkWell(
        onTap: (){_navigateTo(context, jour.label, "L1");},
        splashColor: Colors.brown,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2.0,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              jourColor(),
              jourData(jour),
            ],
          ),
        ),
      );

  Widget jourColor() => new Container(
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white70,
            blurRadius: 5.0,
          ),
        ]),
      );

  Widget jourData(Jour jour) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Text(
            jour.label,
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          )
        ],
      );
 
  //bodygrid
  Widget bodyGrid(List<Jour> jours) => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(_context).orientation == Orientation.portrait
                  ? 2
                  : 3,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return jourStack(context, jours[index]);
        }, childCount: jours.length),
      );

  Widget homeScaffold(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Scaffold(key: _scaffoldState, body: bodySliverList()),
      );

  Widget bodySliverList() {
    JourBloc jourBloc = JourBloc();
    return StreamBuilder<List<Jour>>(
        stream: jourBloc.jours,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: <Widget>[
                    //appBar(),
                    bodyGrid(snapshot.data),
                  ],
                )
              : Center(child: CircularProgressIndicator());
        });
  }

  _navigateTo(context, String jour, String classe) {
    Routes.navigateTo(
      context,
      '/journee/$classe/$jour',
      transition: TransitionType.fadeIn
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    //deviceSize = MediaQuery.of(context).size;
    return homeScaffold(context);
  }
  
}
