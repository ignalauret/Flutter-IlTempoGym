import 'package:flutter/material.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/screens/login_screen.dart';
import 'package:iltempo/screens/reserve_screeen.dart';
import 'package:iltempo/screens/training_detail_screen.dart';
import 'package:provider/provider.dart';
import 'screens/menu_dashboard_screen.dart';
import 'providers/trainings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Trainings>(
          create: (ctx) => Trainings(null),
          update: (ctx, auth, previousTrainings) => Trainings(auth.token),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Il Tempo',
          theme: ThemeData(
            canvasColor: Colors.transparent,
            primarySwatch: Colors.blue,
            accentColor: const Color(0xffe36e61),
          ),
          // If i am authenticated, start at home page, else go to login screen.
          home: authData.isAuth ? MenuDashboardPage() : LoginScreen(),
          routes: {
            TrainingDetailScreen.routeName: (context) => TrainingDetailScreen(),
            ReserveScreen.routeName: (context) => ReserveScreen(),
          },
        ),
      ),
    );
  }
}
