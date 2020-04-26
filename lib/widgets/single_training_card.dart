import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/screens/reserve_screeen.dart';
import 'package:iltempo/screens/training_detail_screen.dart';
import 'package:iltempo/utils/constants.dart';

class SingleTrainingCard extends StatelessWidget {
  SingleTrainingCard(this.training);
  final Training training;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(TrainingDetailScreen.routeName, arguments: training);
      },
      child: Card(
        color: Colors.black,
        margin: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                training.imageUrl,
                alignment: Alignment.center,
                color: Colors.black38,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned(
              child: Column(
                children: <Widget>[
                  Text(
                    training.name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    training.teacher,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: const Color(0xff9a9491),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              bottom: 20,
              left: 15,
            ),
            Positioned(
              child: FlatButton(
                child: Text("Sacar Turno"),
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
                ),
              ),
              bottom: 11,
              right: 15,
            ),
          ],
        ),
      ),
    );
  }
}
