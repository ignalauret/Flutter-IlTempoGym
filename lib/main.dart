import 'package:flutter/material.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/providers/turns.dart';
import 'package:iltempo/screens/home_page.dart';
import 'package:iltempo/screens/login_screen.dart';
import 'package:iltempo/screens/profile_screen.dart';
import 'package:iltempo/screens/reserve_screeen.dart';
import 'package:iltempo/screens/splash_screen.dart';
import 'package:iltempo/screens/training_detail_screen.dart';
import 'package:provider/provider.dart';
import 'providers/trainings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Turns>(
          create: (ctx) => Turns(null, null),
          update: (ctx, auth, previousTrainings) =>
              Turns(auth.token, auth.userDni),
        ),
        ChangeNotifierProxyProvider<Auth, Trainings>(
          create: (ctx) => Trainings(null),
          update: (ctx, auth, previousTrainings) => Trainings(auth.token),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Il Tempo',
          theme: ThemeData(
            canvasColor: Colors.transparent,
            primarySwatch: Colors.blue,
            accentColor: const Color(0xffe36e61),
          ),
          // If i am authenticated, start at home page, else go to login screen.
          home: authData.isAuth
              ? HomePage()
              : FutureBuilder(
                  future: authData.tryAutoLogIn(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
          routes: {
            TrainingDetailScreen.routeName: (context) => TrainingDetailScreen(),
            ReserveScreen.routeName: (context) => ReserveScreen(),
            ProfileScreen.routeName: (context) => ProfileScreen(),
          },
        ),
      ),
    );
  }
}
