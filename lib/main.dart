import 'package:flutter/material.dart';
import 'package:busmap/Router.dart';
import 'screens/HomePage.dart';
import 'package:busmap/service/http_override.dart'; // Import file override SSL
import 'dart:io';
import 'package:busmap/theme/mapdung.dart';
import 'screens/RouterBusStop/DetailBus.dart';
import 'screens/Login/welcome_screen.dart';

import 'package:busmap/ui.dart';




void main() {
  FluroRouterConfig.setupRouter(); // Quan trọng!
  HttpOverrides.global = MyHttpOverrides(); // Kích hoạt bỏ qua SSL
  runApp(BusMapApp());
}

class BusMapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: FluroRouterConfig.router.generator,
      home: WelcomeScreen(),
    );
  }
}

