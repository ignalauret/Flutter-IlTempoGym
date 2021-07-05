import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/providers/trainings.dart';
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
  bool _tapped = false;
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
        if (counts.containsKey(hour)) {
          counts[hour]++;
          // If the turn is from the active user, check the hasReserved
          // flag for this hour.
          if (turnDni == dni) hasReserved[hour] = true;
        }
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
          compareHours(schedule, DateTime.now())) {
        return;
      }
      // Check if it exists.
      if (!counts.containsKey(DateFormat("H:mm").format(schedule))) {
        counts[DateFormat("H:mm").format(schedule)] = 0;
        hasReserved[DateFormat("H:mm").format(schedule)] = false;
      }
    });
  }

  void showSuccessDialog(BuildContext context, {bool expireWarning = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)),
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
          "Turno reservado para ${training.name} el dia ${nextClassDay(parsedSchedule).day.toString() + "/" + nextClassDay(parsedSchedule).month.toString()} a las $selectedHour." +
              (expireWarning
                  ? " No olvide que su cuota vence en menos de una semana!"
                  : ""),
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

  void showErrorDialog(BuildContext context, int code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)),
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
          getMessageCode(code),
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

  String getMessageCode(int code) {
    switch (code) {
      case 400:
        return "Lo sentimos, su cuota ya venció. Comuníquese con el gimnasio para abonarla y no perder su entrenamiento!";
      case 401:
        return "Lo sentimos, este turno ya no está dispoible, intente reservar otro horario.";
      default:
        return "Lo sentimos hubo un error, intente de nuevo mas tarde.";
    }
  }

  int getMaxCount(String selectedHour) {
    if (training.name != "Musculación") return training.maxSchedules;
    final DateTime date = nextClassDay(parsedSchedule);
    final parsedHour = getParsedHour(selectedHour);
    final DateTime selectedDate =
        DateTime(date.year, date.month, date.day, parsedHour[0], parsedHour[1]);
    final maxSchedules = Provider.of<Trainings>(context, listen: false)
        .getMaxSchedule(training, selectedDate);
    return maxSchedules;
  }

  List<Widget> _buildHourSelector(Training training) {
    if (training == null) return [];
    final DateTime nextDay = nextClassDay(parsedSchedule);
    if (selectedHour.isEmpty && parsedSchedule.isNotEmpty)
      selectedHour = DateFormat("H:mm").format(parsedSchedule.firstWhere(
          (schedule) =>
              schedule.weekday == nextDay.weekday &&
              (DateTime.now().weekday != nextDay.weekday ||
                  !compareHours(schedule, DateTime.now()))));
    List<Widget> result = [];
    parsedSchedule
        .where((schedule) =>
            schedule.weekday == nextDay.weekday &&
            (DateTime.now().weekday != nextDay.weekday ||
                !compareHours(schedule, DateTime.now())))
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return fetchTurns(training);
          },
          color: kMainColor,
          backgroundColor: Colors.white70,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: size.height * 0.02,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
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
                            top: 8,
                            left: size.width * 0.02,
                            child: FlatButton(
                              padding: EdgeInsets.only(
                                  left: 0, right: size.width * 0.05),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.chevron_left,
                                    size: 25,
                                    color: kMainColor,
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
                                    BorderRadius.circular(kBorderRadius),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                      InfoCard("Actividad",
                          training == null ? "Cargando..." : training.name),
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
                                style: kTitleStyle,
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
                        alignment: Alignment.center,
                        child: Text(
                          _loading || training == null
                              ? "Cargando..."
                              : hasReserved[selectedHour]
                                  ? "Usted ya tiene una reserva para esta clase."
                                  : counts[selectedHour] <
                                          getMaxCount(selectedHour)
                                      ? "Anotados para las $selectedHour: ${counts[selectedHour]} de ${getMaxCount(selectedHour)}"
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
                Container(
                  height: 60,
                  width: size.width * 0.6,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: FlatButton(
                    child: Text(
                      "Sacar Turno",
                      style: kTitleStyle,
                    ),
                    onPressed: (_loading ||
                            _tapped ||
                            training == null ||
                            counts[selectedHour] >= getMaxCount(selectedHour) ||
                            hasReserved[selectedHour])
                        ? null
                        : () {
                            setState(() {
                              _tapped = true;
                            });
                            Provider.of<Turns>(context, listen: false)
                                .createTurn(
                              context: context,
                              training: training,
                              dni: dni,
                              name: name,
                              date: nextClassDay(parsedSchedule)
                                      .day
                                      .toString() +
                                  "/" +
                                  nextClassDay(parsedSchedule).month.toString(),
                              hour: selectedHour,
                            )
                                .then((code) {
                              if (code == 200)
                                showSuccessDialog(context);
                              else if (code == 201)
                                showSuccessDialog(context, expireWarning: true);
                              else
                                showErrorDialog(context, code);
                            });
                          },
                    textColor: Colors.white,
                    color: kMainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    disabledColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
