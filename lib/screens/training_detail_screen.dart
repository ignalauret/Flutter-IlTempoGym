import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/screens/reserve_screeen.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/widgets/schedule_card.dart';

class TrainingDetailScreen extends StatelessWidget {
  static const String routeName = "/detailScreen";
  final List<String> days = ["Lun", "Mar", "Mie", "Jue", "Vie"];

  @override
  Widget build(BuildContext context) {
    final Training training = ModalRoute.of(context).settings.arguments;

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
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25)),
                  child: Image.asset(
                    "assets/img/musculacion2.jpg",
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 15,
                    bottom: 10,
                  ),
                  child: Text(
                    "Horarios",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.14,
              margin: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => ScheduleCard(
                  day: days[index],
                  hours: training.schedule[days[index]],
                ),
                itemCount: 5,
              ),
            ),
            Text(
              training.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            FlatButton(
              child: Text("Sacar Turno"),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.25,
                  vertical: 10),
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
                borderRadius: BorderRadius.circular(20),
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
