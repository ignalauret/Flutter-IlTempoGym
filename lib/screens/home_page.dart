import 'package:flutter/material.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/widgets/trainings_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  static const routeName = "/home";

  HomePage(this.buildMenuButton);
  final Function buildMenuButton;

  @override
  Widget build(BuildContext context) {
    final trainingsData = Provider.of<Trainings>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Nuestras Clases",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: buildMenuButton(),
      ),
      body: TrainingsList(trainingsData.trainings),
    );
  }
}
