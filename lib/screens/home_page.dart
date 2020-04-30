import 'package:flutter/material.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/screens/profile_screen.dart';
import 'package:iltempo/widgets/trainings_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage(this.buildMenuButton);
  final Function buildMenuButton;

  @override
  Widget build(BuildContext context) {
    final trainingsData = Provider.of<Trainings>(context, listen: false);
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
        ],
      ),
      body: TrainingsList(trainingsData.trainings),
    );
  }
}
