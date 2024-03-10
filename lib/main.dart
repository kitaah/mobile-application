import 'package:flutter/material.dart' show BuildContext, Colors, Key, MaterialApp, StatelessWidget, ThemeData, Widget, runApp;
import 'home_page.dart' show MyHomePage;

void main() {
  // Runs the application with MyApp as the root widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Title displayed in the OS's task switcher.
      title: '(RE)SOURCES RELATIONNELLES',
      // Theme data for the application.
      theme: ThemeData(
        // Primary color swatch for the application.
        primarySwatch: Colors.blue,
        // Font family used throughout the application.
        fontFamily: 'Marianne-Regular',
      ),
      // Home page of the application.
      home: const MyHomePage(title: 'Ressources'),
    );
  }
}
