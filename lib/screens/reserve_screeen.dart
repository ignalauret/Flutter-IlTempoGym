import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/utils/utils.dart';
import 'package:iltempo/widgets/info_card.dart';
import 'package:iltempo/widgets/select_day_card.dart';
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
  String lastName = " ";
  String dni = "Cargando...";

  Training training;

  Map<String, int> counts = {};
  String selectedHour = "";
  bool _loading = true;

  Future<void> fetchTrainings(Training training) async {
    try {
      final response = await http.get(training.dbUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (counts.keys.length > 0) {
        counts.clear();
        _createCountsMap(training);
      }
      if (extractedData == null) {
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
          counts[hour]++;
        });
        _loading = false;
      });
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchUserData() async {
    final authData = Provider.of<Auth>(context, listen: false);
    final response = await http.get(
        "https://il-tempo-dda8e.firebaseio.com/usuarios/${authData.userId}.json?auth=${authData.token}");
    final responseData = json.decode(response.body);
    if (responseData == null) return;
    if (responseData["error"] != null) {
      // Hubo un error
      return;
    }
    setState(() {
      name = responseData["nombre"];
      lastName = responseData["apellido"];
      dni = responseData["dni"].toString();
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      training = ModalRoute.of(context).settings.arguments;
      print("countsMap");
      _createCountsMap(training);
      print("FetchTrainings");
      fetchTrainings(training);
      print("UserData");
      fetchUserData();
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
      }
    });
  }

  void createTurn(Training training) {
    if (counts[selectedHour] >= training.maxSchedules || selectedHour.isEmpty)
      return;
    final authData = Provider.of<Auth>(context, listen: false);
    final url = training.dbUrl;
    http.post(
      url,
      body: json.encode({
        "dni": dni,
        "nombre": name + " " + lastName,
        "clase": training.name,
        "dia": intToDay(nextClassDay(training.schedule).weekday),
        "hora": selectedHour,
        "uid": authData.userId,
      }),
    );
  }

  List<Widget> _buildHourSelector(Training training) {
    final DateTime nextDay = nextClassDay(training.schedule);
    if(selectedHour.isEmpty) selectedHour = DateFormat("H:mm").format(training.schedule.firstWhere((schedule) => schedule.weekday == nextDay.weekday));
    List<Widget> result = [];
    training.schedule
        .where((schedule) => schedule.weekday == nextDay.weekday)
        .forEach(
          (schedule) => result.add(
            SelectDayCard(DateFormat("H:mm").format(schedule),
                selectedHour == DateFormat("H:mm").format(schedule), onHourTap),
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
    print("StartingBuild");
    final size = MediaQuery.of(context).size;
    training = ModalRoute.of(context).settings.arguments;
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
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(10),
                            height: size.height * 0.3,
                            width: double.infinity,
                            child: Image.asset(
                              "assets/img/logo_il_tempo.png",
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 5,
                            child: FlatButton(
                              padding:
                                  const EdgeInsets.only(left: 0, right: 10),
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
                                borderRadius: BorderRadius.circular(15),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        width: size.width,
                        height: size.height * 0.12,
                        child: Column(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Elige un horario",
                                  textAlign: TextAlign.start,
                                  style: TITLE_STYLE,
                                )),
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
                              : counts[selectedHour] < training.maxSchedules
                                  ? "Anotados para las $selectedHour: ${counts[selectedHour]} de ${training.maxSchedules}"
                                  : "Lo sentimos, la clase de las $selectedHour está llena",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      InfoCard("Nombre", name + " " + lastName),
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
                          selectedHour.isEmpty)
                      ? null
                      : () {
                          createTurn(training);
                          Navigator.pop(context);
                        },
                  textColor: Colors.white,
                  color: MAIN_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
