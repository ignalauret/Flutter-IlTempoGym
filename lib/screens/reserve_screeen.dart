import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  List<DateTime> parsedSchedule = [];

  Future<void> fetchTurns(Training training) async {
    if (training == null) return;
    final turns = await Provider.of<Turns>(context, listen: false)
        .getTurnsOfDay(
            nextClassDay(parsedSchedule).day.toString() +
                "/" +
                nextClassDay(parsedSchedule).month.toString(),
            training.name);
    turns.forEach(
      (turn) {
        String hour = turn.hour;
        String turnDni = turn.dni;
        // Increase turns count of this turns day.
        counts[hour]++;
        // If the turn is from the active user, check the hasReserved
        // flag for this hour.
        if (turnDni == dni) hasReserved[hour] = true;
      },
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      training = ModalRoute.of(context).settings.arguments;
      final authData = Provider.of<Auth>(context, listen: false);
      name = authData.userName;
      dni = authData.userDni;
      parsedSchedule = training.getParsedSchedule();
      _createCountsMap(training);
      fetchTurns(training);
    });
    super.initState();
  }

  void _createCountsMap(Training training) {
    if (counts.keys.length > 0) return;
    final DateTime nextDay = nextClassDay(parsedSchedule);
    parsedSchedule.forEach((schedule) {
      // Check if is the same day.
      if (schedule.weekday != nextDay.weekday) return;
      // Check if the class is today and has passed.
      if (schedule.weekday == DateTime.now().weekday &&
          compareHours(schedule, DateTime.now())) return;
      // Check if it exists.
      if (!counts.containsKey(DateFormat("H:mm").format(schedule))) {
        counts[DateFormat("H:mm").format(schedule)] = 0;
        hasReserved[DateFormat("H:mm").format(schedule)] = false;
      }
    });
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CARD_COLOR,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BORDER_RADIUS)),
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
          "Turno reservado para ${training.name} el dia ${nextClassDay(parsedSchedule).day.toString() + "/" + nextClassDay(parsedSchedule).month.toString()} a las $selectedHour",
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

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CARD_COLOR,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BORDER_RADIUS)),
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
          Icons.error,
          size: 45,
          color: Colors.red,
        ),
        content: Text(
          "Lo sentimos hubo un error, intente de nuevo mas tarde.",
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
    if (training == null) return [];
    final DateTime nextDay = nextClassDay(parsedSchedule);
    if (selectedHour.isEmpty && parsedSchedule.isNotEmpty)
      selectedHour = DateFormat("H:mm").format(parsedSchedule
          .firstWhere((schedule) => schedule.weekday == nextDay.weekday));
    List<Widget> result = [];
    parsedSchedule
        .where((schedule) => schedule.weekday == nextDay.weekday)
        .forEach(
          (schedule) => result.add(
            Container(
              height: 30,
              width: 120,
              child: SelectHourCard(
                DateFormat("H:mm").format(schedule),
                selectedHour == DateFormat("H:mm").format(schedule),
                onHourTap,
                MediaQuery.of(context).size,
              ),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () {
          return fetchTurns(training);
        },
        color: MAIN_COLOR,
        backgroundColor: Colors.white70,
        child: Column(
          children: <Widget>[
            Container(
              height: size.height - 65,
              width: size.width,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
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
                                      borderRadius:
                                          BorderRadius.circular(BORDER_RADIUS),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                            InfoCard(
                                "Actividad",
                                training == null
                                    ? "Cargando..."
                                    : training.name),
                            InfoCard(
                                "Dia",
                                counts.isEmpty
                                    ? "Cargando..."
                                    : formatDate(nextClassDay(parsedSchedule))),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: size.height * 0.007,
                              ),
                              width: size.width,
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Elige un horario",
                                      style: TITLE_STYLE,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: size.width,
                                    child: GridView(
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 80,
                                        childAspectRatio: 3 / 2,
                                      ),
                                      padding: const EdgeInsets.all(0),
                                      shrinkWrap: true,
                                      children: _buildHourSelector(training),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: Text(
                                _loading || training == null
                                    ? "Cargando..."
                                    : hasReserved[selectedHour]
                                        ? "Usted ya tiene una reserva para esta clase."
                                        : counts[selectedHour] <
                                                training.maxSchedules
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
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 65,
              width: size.width,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 10,
              ),
              child: FlatButton(
                child: Text("Sacar Turno"),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.25, vertical: 10),
                onPressed: (_loading ||
                        training == null ||
                        counts[selectedHour] >= training.maxSchedules ||
                        hasReserved[selectedHour])
                    ? null
                    : () {
                        Provider.of<Turns>(context, listen: false)
                            .createTurn(
                          training: training,
                          dni: dni,
                          name: name,
                          day: intToDay(nextClassDay(parsedSchedule).weekday),
                          date: nextClassDay(parsedSchedule).day.toString() +
                              "/" +
                              nextClassDay(parsedSchedule).month.toString(),
                          hour: selectedHour,
                        )
                            .then((value) {
                          if (value) showSuccessDialog(context);
                          else showErrorDialog(context);
                        });
                      },
                textColor: Colors.white,
                color: MAIN_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BORDER_RADIUS),
                ),
                disabledColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
