import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/screens/profile_screen.dart';
import 'package:iltempo/widgets/trainings_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
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
      body: FutureBuilder<List<Training>>(
        future: trainingsData.fetchTrainings(),
        builder: (ctx, snapshot) {
          if(snapshot.data == null) {
            return Center(child: CircularProgressIndicator(),);
          } else {
            return(TrainingsList(snapshot.data));
          }
        },
      ),
    );
  }
}
