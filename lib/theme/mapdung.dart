import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(mapDung());
}

class mapDung extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final String apiKey = "5b3ce3597851110001cf6248e0883d07791c4641899a71f24f933f5d"; // API Key
  List<LatLng> routePoints = [];

  LatLng startPoint = LatLng(10.7769, 106.7009); // Hồ Chí Minh
  LatLng endPoint = LatLng(10.7755, 106.6959); // Điểm gần đó
  LatLng? currentPosition; // Vị trí hiện tại của người dùng
  double _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndStartTracking(); // Bắt đầu theo dõi vị trí
    _getRoute(); // Lấy tuyến đường ban đầu
  }

  // Kiểm tra quyền và bắt đầu theo dõi vị trí
  Future<void> _checkPermissionAndStartTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ định vị có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng bật dịch vụ định vị!")),
      );
      return;
    }

    // Kiểm tra và yêu cầu quyền
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Quyền định vị bị từ chối!")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quyền định vị bị từ chối vĩnh viễn!")),
      );
      return;
    }

    // Bắt đầu lắng nghe vị trí thời gian thực
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Cập nhật khi di chuyển 10m
      ),
    ).listen((Position position) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(currentPosition!, _currentZoom); // Cập nhật trung tâm bản đồ
      });
    });
  }

  Future<void> _getRoute() async {
    final url = Uri.parse("https://api.openrouteservice.org/v2/directions/driving-car/geojson");

    final body = jsonEncode({
      "coordinates": [
        [startPoint.longitude, startPoint.latitude],
        [endPoint.longitude, endPoint.latitude]
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": apiKey,
          "Content-Type": "application/json"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey("features") && data["features"].isNotEmpty) {
          final List<dynamic> coordinates =
          data["features"][0]["geometry"]["coordinates"];

          setState(() {
            routePoints = coordinates
                .map((point) => LatLng(point[1], point[0]))
                .toList();
          });
        } else {
          print("Không có tuyến đường được trả về!");
        }
      } else {
        print("Lỗi tải tuyến đường: ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
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
      appBar: AppBar(title: Text("Theo dõi vị trí thời gian thực")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition ?? startPoint,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (currentPosition != null)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: currentPosition!,
                      child: Icon(Icons.my_location, color: Colors.blue, size: 40),
                    ),
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: startPoint,
                    child: Icon(Icons.location_on, color: Colors.green, size: 40),
                  ),
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: endPoint,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6.0,
                      color: Colors.blue,
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
                  onPressed: _zoomIn,
                  child: Icon(Icons.add),
                  mini: true,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  child: Icon(Icons.remove),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}