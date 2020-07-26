import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(App());
  if (!Foundation.kReleaseMode) {
    Wakelock.enable();
  } //REMOVE WHEN PUBLISHING
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apeiron',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.blueAccent[300],
        buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'apeiron'),
    );
  }
}
