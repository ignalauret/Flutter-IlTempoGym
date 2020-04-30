import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iltempo/models/turn.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/providers/turns.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/widgets/turns_list_item.dart';
import 'package:provider/provider.dart';

class TurnsList extends StatelessWidget {
  TurnsList(this.dni);
  final String dni;

  @override
  Widget build(BuildContext context) {

    final trainingData = Provider.of<Trainings>(context).trainings;
    final turnsData = Provider.of<Turns>(context);
    List<String> urls = [];
    trainingData.forEach((training) => urls.add(training.dbUrl));

    return FutureBuilder(
      future: turnsData.getUsersTurns(urls),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          if (snapshot.hasData) {
            return (snapshot.data.isEmpty)
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        "No tienes turnos.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      TurnsListItem(
                          Turn(
                              training: "Clase",
                              hour: "Hora",
                              day: "Fecha",
                              date: " "),
                          MAIN_COLOR),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),

                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return TurnsListItem(
                                snapshot.data[index], Colors.white);
                          },
                        ),
                      )
                    ],
                  );
          }
        }
        return new Container(
          alignment: AlignmentDirectional.center,
          child: new CircularProgressIndicator(),
        );
      },
    );
  }
}
