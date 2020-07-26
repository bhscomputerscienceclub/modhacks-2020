import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(App());

  Wakelock.enable(); //REMOVE WHEN PUBLISHING
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apeiron',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Apeiron'),
    );
  }
}
