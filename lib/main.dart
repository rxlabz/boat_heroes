import 'package:flutter/material.dart';

import 'details_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      routes: {
        'home': (context) => HomeScreen(),
        'details': (context) => DetailScreen(),
      },
    );
  }
}


