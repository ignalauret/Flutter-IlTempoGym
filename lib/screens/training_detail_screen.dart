import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/screens/reserve_screeen.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/utils/utils.dart';
import 'package:iltempo/widgets/info_card.dart';
import 'package:iltempo/widgets/schedule_card.dart';

class TrainingDetailScreen extends StatelessWidget {
  static const String routeName = "/detailScreen";
  final List<String> days = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab"];

  @override
  Widget build(BuildContext context) {
    final Training training = ModalRoute.of(context).settings.arguments;
    final descriptions = training.description.split(("."));
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(BORDER_RADIUS),
                      bottomLeft: Radius.circular(BORDER_RADIUS)),
                  child: Image.asset(
                    training.bannerUrl,
                    color: Colors.black38,
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                Positioned(
                  child: Text(
                    training.name,
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                  bottom: 15,
                  right: 20,
                ),
                Positioned(
                  top: 30,
                  left: 5,
                  child: FlatButton(
                    padding: const EdgeInsets.only(left: 0, right: 10),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 15,
                    bottom: 10,
                  ),
                  child: Text(
                    "Horarios",
                    textAlign: TextAlign.center,
                    style: TITLE_STYLE,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    right: 20,
                    top: 15,
                    bottom: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Duración: ${training.duration}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: size.width,
              height: size.height * 0.15,
              margin: EdgeInsets.only(
                left: 0,
                right: 0,
                top: 0,
                bottom: size.height * 0.006,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => ScheduleCard(
                  day: days[index],
                  hours: hoursOfDay(
                    training.schedule,
                    days[index],
                  ),
                  size: size,
                  withSaturday: training.name == "Musculación",
                ),
                itemCount: training.name == "Musculación" ? 6 : 5,
              ),
            ),
            InfoCard("Profesor", training.teacher),
            Expanded(
              child: Container(
                margin:
                    EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.005),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: descriptions
                      .map(
                        (description) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.check,
                              color: MAIN_COLOR,
                              size: 20,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            FlatButton(
              child: Text("Sacar Turno"),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.25, vertical: 10),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ReserveScreen.routeName,
                  arguments: training,
                );
              },
              textColor: Colors.white,
              color: MAIN_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
                side: BorderSide(
                  color: MAIN_COLOR,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
