import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/providers/turns.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/utils/utils.dart';
import 'package:iltempo/widgets/info_card.dart';
import 'package:iltempo/widgets/select_hour_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/training.dart';

class ReserveScreen extends StatefulWidget {
  static const routeName = "/reserve";

  @override
  _ReserveScreenState createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  String name = "Cargando...";
  String dni = "Cargando...";

  Training training;

  Map<String, int> counts = {};
  Map<String, bool> hasReserved = {};
  String selectedHour = "";
  bool _loading = true;

  Future<void> fetchTrainings(Training training) async {
    try {
      final response = await http.get(training.dbUrl +
          '&orderBy="fecha"&equalTo="${nextClassDay(training.schedule).day.toString() + "/" + nextClassDay(training.schedule).month.toString()}"');
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (counts.keys.length > 0) {
        counts.clear();
        _createCountsMap(training);
      }
      if (extractedData == null || extractedData.length == 0) {
        setState(() {
          _loading = false;
        });
        return;
      }
      if (extractedData["error"] != null) {
        //Hubo un error
        return;
      }
      setState(() {
        extractedData.forEach((key, data) {
          String hour = data["hora"];
          String turnDni = data["dni"];
          counts[hour]++;
          if (turnDni == dni) hasReserved[hour] = true;
        });
        _loading = false;
      });
    } catch (error) {
      throw (error);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      training = ModalRoute.of(context).settings.arguments;
      _createCountsMap(training);
      fetchTrainings(training);
    });
    super.initState();
  }

  void _createCountsMap(Training training) {
    if (counts.keys.length > 0) return;
    final DateTime nextDay = nextClassDay(training.schedule);
    training.schedule.forEach((schedule) {
      if (schedule.weekday != nextDay.weekday) return;
      if (!counts.containsKey(DateFormat("H:mm").format(schedule))) {
        counts.addAll({DateFormat("H:mm").format(schedule): 0});
        hasReserved.addAll({DateFormat("H:mm").format(schedule): false});
      }
    });
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CARD_COLOR,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
        contentPadding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 0,
        ),
        titlePadding: const EdgeInsets.only(
          top: 20,
          bottom: 0,
          left: 20,
          right: 20,
        ),
        title: Icon(
          Icons.check,
          size: 45,
          color: Colors.green,
        ),
        content: Text(
          "Turno reservado para ${training.name} el dia ${nextClassDay(training.schedule).day.toString() + "/" + nextClassDay(training.schedule).month.toString()} a las $selectedHour",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    ).then((_) => Navigator.of(context).pop());
  }

  List<Widget> _buildHourSelector(Training training) {
    final DateTime nextDay = nextClassDay(training.schedule);
    if (selectedHour.isEmpty)
      selectedHour = DateFormat("H:mm").format(training.schedule
          .firstWhere((schedule) => schedule.weekday == nextDay.weekday));
    List<Widget> result = [];
    training.schedule
        .where((schedule) => schedule.weekday == nextDay.weekday)
        .forEach(
          (schedule) => result.add(
            SelectHourCard(
              DateFormat("H:mm").format(schedule),
              selectedHour == DateFormat("H:mm").format(schedule),
              onHourTap,
              MediaQuery.of(context).size,
            ),
          ),
        );
    return result;
  }

  void onHourTap(String hour) {
    setState(() {
      selectedHour = hour;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    training = ModalRoute.of(context).settings.arguments;
    final authData = Provider.of<Auth>(context);
    final turnsData = Provider.of<Turns>(context);

    name = authData.userName;
    dni = authData.userDni;
    _createCountsMap(training);
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () {
          return fetchTrainings(training);
        },
        color: MAIN_COLOR,
        backgroundColor: Colors.white70,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: size.height,
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: size.height * 0.3,
                            width: double.infinity,
                            child: Image.asset(
                              "assets/img/logo_il_tempo.png",
                            ),
                          ),
                          Positioned(
                            top: size.height * 0.035,
                            left: size.width * 0.02,
                            child: FlatButton(
                              padding: EdgeInsets.only(
                                  left: 0, right: size.width * 0.05),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 25,
                                    color: MAIN_COLOR,
                                  ),
                                  Text(
                                    "Volver",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              color: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(BORDER_RADIUS),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                      InfoCard("Actividad", training.name),
//                Container(
//                  padding: const EdgeInsets.symmetric(
//                    horizontal: 15,
//                    vertical: 5,
//                  ),
//                  width: size.width,
//                  height: size.height * 0.12,
//                  child: Column(
//                    children: <Widget>[
//                      Align(
//                          alignment: Alignment.centerLeft,
//                          child: Text(
//                            "Elige un dia",
//                            textAlign: TextAlign.start,
//                            style: TITLE_STYLE,
//                          )),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: _buildDaySelector(training),
//                      ),
//                    ],
//                  ),
//                ),
                      InfoCard(
                          "Dia",
                          counts.isEmpty
                              ? "Cargando..."
                              : formatDate(nextClassDay(training.schedule))),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: size.height * 0.007,
                        ),
                        width: size.width,
                        height: size.height * 0.12,
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Elige un horario",
                                style: TITLE_STYLE,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.005,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildHourSelector(training),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Text(
                          _loading
                              ? "Cargando..."
                              : hasReserved[selectedHour]
                                  ? "Usted ya tiene una reserva para esta clase."
                                  : counts[selectedHour] < training.maxSchedules
                                      ? "Anotados para las $selectedHour: ${counts[selectedHour]} de ${training.maxSchedules}"
                                      : "Lo sentimos, la clase de las $selectedHour está llena",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      InfoCard("Nombre", name),
                      InfoCard("Dni", dni),
                    ],
                  ),
                ),
                FlatButton(
                  child: Text("Sacar Turno"),
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.25, vertical: 10),
                  onPressed: (_loading ||
                          counts[selectedHour] >= training.maxSchedules ||
                          hasReserved[selectedHour])
                      ? null
                      : () {
                          turnsData.createTurn(
                            training: training,
                            dni: dni,
                            name: name,
                            day: intToDay(
                                nextClassDay(training.schedule).weekday),
                            date:
                                nextClassDay(training.schedule).day.toString() +
                                    "/" +
                                    nextClassDay(training.schedule)
                                        .month
                                        .toString(),
                            hour: selectedHour,
                          );
                          showSuccessDialog(context);
                        },
                  textColor: Colors.white,
                  color: MAIN_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BORDER_RADIUS),
                  ),
                  disabledColor: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
