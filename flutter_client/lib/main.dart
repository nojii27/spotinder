import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SpoTinder/RouteGenerator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SpoTinder',
        theme: ThemeData(
          fontFamily: 'Century Gothic',
          // elevatedButtonTheme: ElevatedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //     elevation: 8,
          //     primary: CupertinoColors.white,
          //     shape: const CircleBorder(),
          //     minimumSize: const Size.square(80),
          //   ),
          // ),
          // button foreground color
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

