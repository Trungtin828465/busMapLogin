import 'package:flutter/material.dart';

import 'package:busmap/Router.dart';
import 'screens/HomePage.dart';
import 'package:busmap/screens/Login/welcome_screen.dart';
import 'package:busmap/theme/theme.dart';
import 'package:busmap/screens/MapGps.dart';
import 'package:busmap/screens/SelectRoute.dart';
import 'package:busmap/screens/MapGpsSearch.dart';
import 'package:busmap/screens/DetailBus.dart';
import 'package:busmap/mapdung.dart';
import 'package:busmap/service/http_override.dart'; // Import file override SSL
import 'dart:io';


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


//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:busmap/service/api_service.dart';
// import 'package:busmap/service/http_override.dart'; // Import file override SSL
// import 'dart:io';
//
// void main() {
//   HttpOverrides.global = MyHttpOverrides(); // Bỏ qua lỗi SSL
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: BusStopsScreen(),
//     );
//   }
// }
//
// class BusStopsScreen extends StatefulWidget {
//   @override
//   _BusStopsScreenState createState() => _BusStopsScreenState();
// }
//
// class _BusStopsScreenState extends State<BusStopsScreen> {
//   List<dynamic> busStops = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadBusStops();
//   }
//
//   void loadBusStops() async {
//     try {
//       final data = await ApiService().fetchBusStops();
//       setState(() {
//         busStops = data;
//       });
//     } catch (e) {
//       print("Lỗi khi gọi API: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Danh sách trạm xe buýt")),
//       body: busStops.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: busStops.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(busStops[index]['name']),
//             subtitle: Text("ID: ${busStops[index]['id']}"),
//           );
//         },
//       ),
//     );
//   }
// }
