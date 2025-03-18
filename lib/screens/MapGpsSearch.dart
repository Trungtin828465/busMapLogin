import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:busmap/screens/SelectRoute.dart';

class MapGpsSearch extends StatefulWidget {
  @override
  _MapGpsState createState() => _MapGpsState();
}

  class _MapGpsState extends State<MapGpsSearch> {
  final MapController _mapController = MapController();
  LatLng _defaultLocation = LatLng(10.8411, 106.8097); // Mặc định: Lê Văn Việt
  LatLng? _currentPosition;
  double _currentZoom = 14.0;

  int _selectedIndex = 0; // Chỉ mục tab được chọn

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusSelectRount()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Hàm lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Nếu chưa cấp quyền, yêu cầu quyền
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("⚠️ Quyền vị trí bị từ chối!");
        return;
      }
    }

    // Nếu bị từ chối vĩnh viễn, mở cài đặt
    if (permission == LocationPermission.deniedForever) {
      print("❌ Quyền vị trí bị chặn! Hãy bật quyền thủ công.");
      await Geolocator.openAppSettings();
      return;
    }

    // Nếu quyền đã được cấp, lấy vị trí
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("📍 Vị trí hiện tại: ${position.latitude}, ${position.longitude}");

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, _currentZoom);
    });
  }

  // Hàm phóng to
  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  // Hàm thu nhỏ
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
          // Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultLocation,
              initialZoom: _currentZoom,
            ),
            children: [
              // Layer bản đồ
              TileLayer(
                urlTemplate: 'https://tile.thunderforest.com/tra'
                    'nsport/{z}/{x}/{y}.png?apikey=30bd60'
                    'a20b974c7c8f4f269a3f66f902',
              ),

              // Marker vị trí hiện tại
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50.0,
                      height: 30.0,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Nút điều khiển: Phóng to, thu nhỏ, lấy vị trí
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
