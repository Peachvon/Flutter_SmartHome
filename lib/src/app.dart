import 'package:flutter/material.dart';
import 'package:smarthome/src/screen/home/air/air_screen.dart';
import 'package:smarthome/src/screen/home/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}
