import 'package:flutter/material.dart';
import 'package:iltempo/models/training.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/providers/trainings.dart';
import 'package:iltempo/screens/profile_screen.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/utils/utils.dart';
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
            color: Colors.white60,
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
      body: SafeArea(
        child: Column(
          children: [
            _buildExpireInfo(context),
            Expanded(
              child: FutureBuilder<List<Training>>(
                future: trainingsData.fetchTrainings(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return (TrainingsList(snapshot.data));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpireInfo(BuildContext context) {
    return Consumer<Auth>(
      builder: (context, authProvider, _) {
        final expireDate = authProvider.userExpireDate;
        String message;
        bool isDanger;
        if (expireDate == null) {
          message = 'Usuario no registrado';
          isDanger = true;
        } else {
          final date = parseDate(expireDate);
          if (date.isBefore(DateTime.now())) {
            message = 'Tu cuota está vencida';
            isDanger = true;
          } else {
            message = 'Cuota activa hasta el ${unParseDate(date)}';
            isDanger = false;
          }
        }

        return Container(
          height: 40,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 22,
                    color: isDanger ? kMainColor : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
