import 'package:flutter/material.dart';
import 'package:iltempo/models/turn.dart';
import 'package:iltempo/providers/turns.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/widgets/turns_list_item.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:provider/provider.dart';

class TurnsList extends StatelessWidget {
  TurnsList(this.dni);
  final String dni;

  @override
  Widget build(BuildContext context) {
    final turnsData = Provider.of<Turns>(context, listen: true);
    return FutureBuilder<List<Turn>>(
      future: turnsData.getUsersTurns(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return (snapshot.data.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      "No tienes turnos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kCardColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Clase",
                                style: TextStyle(color: kMainColor),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Fecha",
                                style: TextStyle(color: kMainColor),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Horario",
                                style: TextStyle(color: kMainColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return TurnsListItem(
                            snapshot.data[index],
                            Colors.white,
                            () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: kCardColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            kBorderRadius)),
                                    contentPadding: const EdgeInsets.only(
                                      top: 20,
                                      left: 20,
                                      right: 20,
                                      bottom: 0,
                                    ),
                                    titlePadding: const EdgeInsets.only(
                                      top: 20,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                    ),
                                    title: Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    content: Text(
                                      "Seguro quiere cancelar el turno de ${snapshot.data[index].training} del ${snapshot.data[index].date} a las ${snapshot.data[index].hour}?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          "Si",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        onPressed: () {
                                          turnsData.cancelTurn(
                                              snapshot.data[index].id,
                                              snapshot.data[index].training);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(
                                          "No",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ),
                                );
                              },
                          );
                        },
                      ),
                    )
                  ],
                );
        }
        return new Container(
          alignment: AlignmentDirectional.center,
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
