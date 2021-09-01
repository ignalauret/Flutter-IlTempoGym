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
  final List<String> days = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", 'Dom'];

  @override
  Widget build(BuildContext context) {
    final Training training = ModalRoute.of(context).settings.arguments;
    final descriptions = training.description.split(("."));
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(kBorderRadius),
                        bottomLeft: Radius.circular(kBorderRadius)),
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
                    top: 8,
                    left: 5,
                    child: FlatButton(
                      padding: const EdgeInsets.only(left: 0, right: 10),
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
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
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
                            style: kTitleStyle,
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
                      child: Row(
                        children: List.generate(
                          7,
                          (index) => ScheduleCard(
                            day: days[index],
                            hours: hoursOfDay(
                              training.schedule,
                              days[index],
                            ),
                            size: size,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Column(
                      children: [
                        InfoCard("Profesor", training.teacher),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: size.width * 0.01,
                          vertical: size.height * 0.005),
                      child: Column(
                        children: descriptions
                            .map(
                              (description) => description.isEmpty
                                  ? Container()
                                  : Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            color: kMainColor,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                            )
                            .toList(),
                      ),
                    ),
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
                  onPressed: () {
                    Navigator.of(context).pushNamed(ReserveScreen.routeName,
                        arguments: training);
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
    );
  }
}
