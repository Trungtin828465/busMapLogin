// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async'; // Import để quản lý StreamSubscription
// import 'dart:math' as math;
// import 'package:flutter_compass/flutter_compass.dart';
//
// class MapGps extends StatefulWidget {
//   @override
//   _MapGpsState createState() => _MapGpsState();
// }
//
// class _MapGpsState extends State<MapGps> {
//   final MapController _mapController = MapController();
//   LatLng _defaultLocation = LatLng(10.8411, 106.8097); // Mặc định: Lê Văn Việt
//   LatLng? _currentPosition;
//   double _currentZoom = 14.0;
//   double _heading = 0.0; // Hướng di chuyển
//   StreamSubscription<Position>? _positionStream; // Lưu Stream để quản lý
//   StreamSubscription<CompassEvent>? _compassStream; // Lưu Compass Stream
//
//   @override
//   void initState() {
//     super.initState();
//     _requestLocationPermission(); // Yêu cầu quyền truy cập vị trí
//     _trackLocation(); // Bắt đầu theo dõi vị trí
//     _trackCompass(); // Bắt đầu theo dõi hướng xoay
//   }
//
//   /// Yêu cầu quyền vị trí trước khi theo dõi
//   Future<void> _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print("⚠️ Quyền vị trí bị từ chối!");
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       print("❌ Quyền vị trí bị chặn! Hãy bật quyền thủ công.");
//       await Geolocator.openAppSettings();
//       return;
//     }
//   }
//
//   /// Theo dõi vị trí liên tục
//   void _trackLocation() {
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5, // Chỉ cập nhật nếu di chuyển ít nhất 5m
//       ),
//     ).listen((Position position) {
//       _updateLocation(position.latitude, position.longitude, position.heading);
//     });
//   }
//
//   /// Theo dõi hướng xoay của thiết bị
//   void _trackCompass() {
//     _compassStream = FlutterCompass.events?.listen((event) {
//       setState(() {
//         _heading = event.heading ?? 0;
//       });
//     });
//   }
//
//   /// Cập nhật vị trí và di chuyển bản đồ
//   void _updateLocation(double lat, double lng, double heading) {
//     setState(() {
//       _currentPosition = LatLng(lat, lng);
//       _heading = heading;
//       _mapController.move(_currentPosition!, _currentZoom);
//     });
//   }
//
//   /// Dừng theo dõi vị trí khi không cần thiết
//   void _stopTracking() {
//     _positionStream?.cancel();
//     _compassStream?.cancel();
//   }
//
//   @override
//   void dispose() {
//     _stopTracking(); // Dừng stream khi thoát màn hình
//     super.dispose();
//   }
//
//   /// Phóng to bản đồ
//   void _zoomIn() {
//     setState(() {
//       _currentZoom += 1;
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }
//
//   /// Thu nhỏ bản đồ
//   void _zoomOut() {
//     setState(() {
//       _currentZoom -= 1;
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Bản đồ
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentPosition ?? _defaultLocation,
//               initialZoom: _currentZoom,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: ['a', 'b', 'c'],
//               ),
//
//               // Marker vị trí hiện tại
//               if (_currentPosition != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _currentPosition!,
//                       width: 50.0,
//                       height: 50.0,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue.withOpacity(0.3),
//                             ),
//                           ),
//                           Container(
//                             width: 30,
//                             height: 30,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue.withOpacity(0.6),
//                             ),
//                           ),
//                           Transform.rotate(
//                             angle: _heading * (math.pi / 180),
//                             child: Icon(
//                               Icons.navigation,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//
//           // Nút điều khiển: Phóng to, thu nhỏ, lấy vị trí
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: "zoomIn",
//                   onPressed: _zoomIn,
//                   child: Icon(Icons.add),
//                   mini: true,
//                   backgroundColor: Colors.green,
//                 ),
//                 SizedBox(height: 10),
//                 FloatingActionButton(
//                   heroTag: "zoomOut",
//                   onPressed: _zoomOut,
//                   child: Icon(Icons.remove),
//                   mini: true,
//                   backgroundColor: Colors.green,
//                 ),
//                 SizedBox(height: 10),
//                 FloatingActionButton(
//                   heroTag: "myLocation",
//                   onPressed: () async {
//                     Position position = await Geolocator.getCurrentPosition(
//                       desiredAccuracy: LocationAccuracy.high,
//                     );
//                     _updateLocation(position.latitude, position.longitude, position.heading);
//                   },
//                   child: Icon(Icons.my_location),
//                   mini: true,
//                   backgroundColor: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math' as math;
// import 'package:flutter_compass/flutter_compass.dart';
// import 'dart:async';
//
// class MapGps extends StatefulWidget {
//   @override
//   _MapGpsState createState() => _MapGpsState();
// }
//
// class _MapGpsState extends State<MapGps> {
//   final MapController _mapController = MapController();
//   LatLng _defaultLocation = LatLng(10.8411, 106.8097);
//   LatLng? _currentPosition;
//   LatLng? _lastPosition;
//   double _currentZoom = 14.0;
//   double _heading = 0.0;
//   StreamSubscription<Position>? _positionStream;
//   StreamSubscription? _compassSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _listenCompass();
//     _trackLocation();
//   }
//
//   @override
//   void dispose() {
//     _positionStream?.cancel(); // Hủy lắng nghe vị trí khi thoát
//     _compassSubscription?.cancel(); // Hủy lắng nghe la bàn khi thoát
//     super.dispose();
//   }
//
//   void _trackLocation() {
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5,
//       ),
//     ).listen((Position position) {
//       if (!mounted) return;
//       LatLng newPosition = LatLng(position.latitude, position.longitude);
//       if (_lastPosition == null || _calculateDistance(_lastPosition!, newPosition) > 2.0) {
//         _updateLocation(newPosition, position.heading);
//         _lastPosition = newPosition;
//       }
//     });
//   }
//
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
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     _updateLocation(LatLng(position.latitude, position.longitude), position.heading);
//   }
//
//   void _updateLocation(LatLng newPosition, double heading) {
//     if (!mounted) return;
//     setState(() {
//       _currentPosition = newPosition;
//       _heading = heading;
//       _mapController.move(_currentPosition!, _currentZoom);
//     });
//   }
//
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
//   double _calculateDistance(LatLng pos1, LatLng pos2) {
//     return Geolocator.distanceBetween(
//       pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude,
//     );
//   }
//
//   void _zoomIn() {
//     setState(() {
//       _currentZoom += 1;
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }
//
//   void _zoomOut() {
//     setState(() {
//       _currentZoom -= 1;
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
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
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//               ),
//               if (_currentPosition != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _currentPosition!,
//                       width: 50.0,
//                       height: 50.0,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue.withOpacity(0.3),
//                             ),
//                           ),
//                           Container(
//                             width: 30,
//                             height: 30,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue.withOpacity(0.6),
//                             ),
//                           ),
//                           Transform.rotate(
//                             angle: _heading * (math.pi / 180),
//                             child: Icon(
//                               Icons.navigation,
//                               color: Colors.white,
//                               size: 25,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: "zoomIn",
//                   onPressed: _zoomIn,
//                   child: Icon(Icons.add),
//                   mini: true,
//                   backgroundColor: Colors.green,
//                 ),
//                 SizedBox(height: 10),
//                 FloatingActionButton(
//                   heroTag: "zoomOut",
//                   onPressed: _zoomOut,
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
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

class MapGps extends StatefulWidget {
  @override
  _MapGpsState createState() => _MapGpsState();
}

class _MapGpsState extends State<MapGps> {
  final MapController _mapController = MapController();
  LatLng _defaultLocation = LatLng(10.8411, 106.8097); // Mặc định: Lê Văn Việt
  LatLng? _currentPosition;
  double _currentZoom = 14.0;
  double _heading = 0.0; // Hướng di chuyển
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
    _trackLocation();
    _trackCompass();
  }

  /// Kiểm tra và yêu cầu quyền vị trí
  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng bật dịch vụ định vị!")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Quyền vị trí bị từ chối!")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quyền vị trí bị từ chối vĩnh viễn! Vào cài đặt để bật.")),
      );
      await Geolocator.openAppSettings();
      return;
    }
  }

  /// Theo dõi vị trí liên tục
  void _trackLocation() {
    _positionStream?.cancel(); // Hủy stream cũ nếu có
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // số càng nhỏ càng mượt
      ),
    ).listen((Position position) {
      _updateLocation(position.latitude, position.longitude, position.heading);
    }, onError: (e) {
      print("Lỗi khi theo dõi vị trí: $e");
    });
  }

  /// Theo dõi hướng xoay của thiết bị
  void _trackCompass() {
    _compassStream?.cancel(); // Hủy stream cũ nếu có
    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    }, onError: (e) {
      print("Lỗi khi theo dõi la bàn: $e");
    });
  }

  /// Cập nhật vị trí và di chuyển bản đồ
  void _updateLocation(double lat, double lng, double? heading) {
    setState(() {
      _currentPosition = LatLng(lat, lng);
      _heading = heading ?? _heading;
      _mapController.move(_currentPosition!, _currentZoom);
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
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
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50.0,
                      height: 50.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.6),
                            ),
                          ),
                          Transform.rotate(
                            angle: _heading * (math.pi / 180),
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  child: const Icon(Icons.add),
                  mini: true,
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                  mini: true,
                  backgroundColor: Colors.green,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "myLocation",
                  onPressed: () async {
                    try {
                      Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      _updateLocation(position.latitude, position.longitude, position.heading);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Không thể lấy vị trí: $e")),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                  mini: true,
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
