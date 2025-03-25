import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:busmap/service/api_service.dart';
import 'package:busmap/Router.dart';

import 'package:busmap/models/BusStopModel/BusStopModel.dart';

class MapGpsSearch extends StatefulWidget {
  @override
  _MapGpsState createState() => _MapGpsState();
}

class _MapGpsState extends State<MapGpsSearch> {
  final MapController _mapController = MapController();
  LatLng _defaultLocation = LatLng(10.8411, 106.8097);
  LatLng? _currentPosition;
  double _currentZoom = 16.5;
  double _heading = 0.0; // Hướng xoay GPS
  List<Marker> _busStopMarkers = [];
  final ApiService _busStopService = ApiService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadBusStops();
    _listenCompass(); // Lắng nghe hướng xoay thiết bị
  }

  /// Lấy hướng xoay của thiết bị
  void _listenCompass() {
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0; // Lưu hướng xoay (độ)
      });
    });
  }

  /// Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("⚠️ Quyền vị trí bị từ chối!");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("❌ Quyền vị trí bị chặn! Hãy bật quyền thủ công.");
      await Geolocator.openAppSettings();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("📍 Vị trí hiện tại: ${position.latitude}, ${position.longitude}");
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, _currentZoom);
    });
  }

  /// Tải danh sách điểm dừng xe buýt
  Future<void> _loadBusStops() async {
    try {
      List<BusStopModel> busStops = await _busStopService.fetchBusStops();
      setState(() {
        _busStopMarkers = busStops.map((busStop) => Marker(
          point: LatLng(busStop.latitude, busStop.longitude),
          width: 30.0,
          height: 30.0,
          child: Icon(
            Icons.directions_bus,
            color: Colors.green,
            size: 30,
          ),
        )).toList();
      });
    } catch (e) {
      print("Lỗi tải điểm dừng: $e");
    }
  }

  /// Zoom In
  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  /// Zoom Out
  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  /// Xử lý chọn BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      FluroRouterConfig.router.navigateTo(
        context, "/selectRouter",

      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(

        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultLocation,
              initialZoom: _currentZoom,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentZoom = position.zoom;
                });
              },

            ),

            children: [
              TileLayer(
                  urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=30bd60a20b974c7c8f4f269a3f66f902',
              ),
              // Nút Back
              Positioned(
                top: 40, // Điều chỉnh vị trí
                left: 10,
                child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                        // Nếu không có trang trước, điều hướng về "/mapSearch"
                        FluroRouterConfig.router.navigateTo(
                          context, "/home",
                          // replace: true,
                        );

                    },
                ),
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50.0,
                      height: 50.0,
                      child: Transform.rotate(
                        angle: _heading * (3.14159265359 / 180),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.3), // Vòng ngoài mờ
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.6), // Vòng trong rõ hơn
                              ),
                            ),
                            Icon(
                              Icons.navigation, // Icon GPS chính
                              color: Colors.white,
                              size: 25,
                            ),
                          ],
                        ),

                      ),
                    ),
                  ],
                ),
              if (_currentZoom >= 16.5) MarkerLayer(markers: _busStopMarkers),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  onPressed: _zoomIn,
                  child: Icon(Icons.add),
                  mini: true,
                  backgroundColor: Colors.green,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  onPressed: _zoomOut,
                  child: Icon(Icons.remove),
                  mini: true,
                  backgroundColor: Colors.green,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "myLocation",
                  onPressed: _getCurrentLocation,
                  child: Icon(Icons.my_location),
                  mini: true,
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tra cứu'),
          BottomNavigationBarItem(icon: Icon(Icons.directions), label: 'Tìm đường'),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:busmap/service/api_service.dart';
// import 'package:busmap/Router.dart';
// import 'dart:async';
//
// import 'package:busmap/models/BusStopModel/BusStopModel.dart';
//
// class MapGpsSearch extends StatefulWidget {
//   @override
//   _MapGpsState createState() => _MapGpsState();
// }
//
// class _MapGpsState extends State<MapGpsSearch> {
//   final MapController _mapController = MapController();
//   final ApiService _busStopService = ApiService();
//
//   LatLng _defaultLocation = LatLng(10.8411, 106.8097);
//   LatLng? _currentPosition;
//   double _currentZoom = 16.5;
//   double _heading = 0.0;
//   List<Marker> _busStopMarkers = [];
//   StreamSubscription? _compassSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _loadBusStops();
//     _listenCompass();
//   }
//
//   /// Lắng nghe hướng xoay thiết bị và hủy khi thoát
//   void _listenCompass() {
//     _compassSubscription = FlutterCompass.events?.listen((event) {
//       if (mounted) {
//         setState(() {
//           _heading = event.heading ?? 0;
//         });
//       }
//     });
//   }
//
//   /// Lấy vị trí hiện tại
//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//     if (permission == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     if (mounted) {
//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//         _mapController.move(_currentPosition!, _currentZoom);
//       });
//     }
//   }
//
//   /// Tải danh sách điểm dừng xe buýt
//   Future<void> _loadBusStops() async {
//     try {
//       List<BusStopModel> busStops = await _busStopService.fetchBusStops();
//       if (mounted) {
//         setState(() {
//           _busStopMarkers = busStops.map((busStop) => Marker(
//             point: LatLng(busStop.latitude, busStop.longitude),
//             width: 30.0,
//             height: 30.0,
//             child: Icon(Icons.directions_bus, color: Colors.green, size: 30),
//           )).toList();
//         });
//       }
//     } catch (e) {
//       print("Lỗi tải điểm dừng: $e");
//     }
//   }
//
//   /// Zoom In / Zoom Out
//   void _changeZoom(double zoomChange) {
//     setState(() {
//       _currentZoom += zoomChange;
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }
//
//   @override
//   void dispose() {
//     _compassSubscription?.cancel(); // Hủy lắng nghe compass khi thoát trang
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentPosition ?? _defaultLocation,
//               initialZoom: _currentZoom,
//               onPositionChanged: (position, hasGesture) {
//                 _currentZoom = position.zoom;
//               },
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=30bd60a20b974c7c8f4f269a3f66f902',
//               ),
//               if (_currentPosition != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _currentPosition!,
//                       width: 50.0,
//                       height: 50.0,
//                       child: Transform.rotate(
//                         angle: _heading * (3.14159265359 / 180),
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.blue.withOpacity(0.3),
//                               ),
//                             ),
//                             Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.blue.withOpacity(0.6),
//                               ),
//                             ),
//                             Icon(Icons.navigation, color: Colors.white, size: 25),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               if (_currentZoom >= 16.5) MarkerLayer(markers: _busStopMarkers),
//             ],
//           ),
//
//           /// Nút Back
//           Positioned(
//             top: 40,
//             left: 10,
//             child: IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 Navigator.pushNamed(context, "/home");              },
//             ),
//           ),
//
//           /// Nút điều khiển
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: "zoomIn",
//                   onPressed: () => _changeZoom(1),
//                   child: Icon(Icons.add),
//                   mini: true,
//                   backgroundColor: Colors.green,
//                 ),
//                 SizedBox(height: 10),
//                 FloatingActionButton(
//                   heroTag: "zoomOut",
//                   onPressed: () => _changeZoom(-1),
//                   child: Icon(Icons.remove),
//                   mini: true,
//                   backgroundColor: Colors.green,
//                 ),
//                 SizedBox(height: 10),
//                 FloatingActionButton(
//                   heroTag: "myLocation",
//                   onPressed: _getCurrentLocation,
//                   child: Icon(Icons.my_location),
//                   mini: true,
//                   backgroundColor: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//
//       /// Thanh điều hướng
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushNamed(context, "/selectRouter");
//           }
//         },
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: Colors.green,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tra cứu'),
//           BottomNavigationBarItem(icon: Icon(Icons.directions), label: 'Tìm đường'),
//         ],
//       ),
//     );
//   }
// }
