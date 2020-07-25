import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:wakelock/wakelock.dart';
import 'package:my_app/database.dart';

void main() {
  runApp(App());

  Wakelock.enable(); //REMOVE WHEN PUBLISHING
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
