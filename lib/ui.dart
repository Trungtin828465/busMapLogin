import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Biến để theo dõi thời gian của yêu cầu trước đó
DateTime? _lastRequestTime;

Future<List<double>> geocodeAddress(String address) async {
  // Kiểm tra thời gian yêu cầu trước đó để đảm bảo không vượt quá 1 yêu cầu/giây
  if (_lastRequestTime != null) {
    final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
    if (timeSinceLastRequest.inMilliseconds < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - timeSinceLastRequest.inMilliseconds));
    }
  }

  // Hàm phụ để gọi Nominatim API
  Future<List<double>?> tryGeocode(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)}&format=json&limit=1&addressdetails=1&countrycodes=VN'
    );


    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'YourAppName/1.0 (your.email@example.com)', // Thay bằng thông tin ứng dụng của bạn
        },
      );

      _lastRequestTime = DateTime.now();

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          final double lat = double.parse(result['lat']);
          final double lon = double.parse(result['lon']);
          print("Geocoded address: $query -> [$lon, $lat]");
          return [lon, lat];
        }
      }
    } catch (e) {
      print("Geocoding error for query $query: $e");
    }
    return null;
  }

  // Thử với địa chỉ gốc
  List<double>? coords = await tryGeocode(address);
  if (coords != null) return coords;

  // Thử đơn giản hóa địa chỉ: Bỏ số nhà
  print("No results found for address: $address, trying without house number...");
  String simplifiedAddress = address.replaceAll(RegExp(r'Số \d+,?'), '').trim();
  coords = await tryGeocode(simplifiedAddress);
  if (coords != null) return coords;

  // Thử bỏ phường
  print("No results found for simplified address: $simplifiedAddress, trying without ward...");
  String withoutWard = simplifiedAddress.replaceAll(RegExp(r'Phường \w+,?'), '').trim();
  coords = await tryGeocode(withoutWard);
  if (coords != null) return coords;

  // Thử chỉ lấy tên đường và quận/thành phố
  print("No results found for address without ward: $withoutWard, trying street and district only...");
  List<String> parts = withoutWard.split(',');
  if (parts.length >= 3) {
    String streetAndDistrict = "${parts[0].trim()}, ${parts[parts.length - 3].trim()}, ${parts[parts.length - 1].trim()}";
    coords = await tryGeocode(streetAndDistrict);
    if (coords != null) return coords;
  }

  // Fallback: Trả về tọa độ trung tâm của khu vực
  print("No results found for street and district: $withoutWard, using fallback...");
  String fallbackAddress = address.toLowerCase();
  if (fallbackAddress.contains("quận 1")) {
    return [106.6993, 10.7798]; // Tọa độ trung tâm Quận 1
  } else if (fallbackAddress.contains("quận 2")) {
    return [106.7351, 10.8032]; // Tọa độ trung tâm Quận 2 (khu vực Thảo Điền)
  } else if (fallbackAddress.contains("quận 3")) {
    return [106.6870, 10.7830]; // Tọa độ trung tâm Quận 3
  } else if (fallbackAddress.contains("quận 5")) {
    return [106.6700, 10.7550]; // Tọa độ trung tâm Quận 5
  } else if (fallbackAddress.contains("thủ đức")) {
    return [106.7009, 10.7769]; // Tọa độ trung tâm Thủ Đức
  } else if (fallbackAddress.contains("hồ chí minh")) {
    return [106.6297, 10.8231]; // Tọa độ trung tâm TP. Hồ Chí Minh
  }

  throw Exception("No results found for address: $address, and no fallback available");
}

// RouteService class to fetch route from OpenRouteService API
class RouteService {
  static const String apiKey = "5b3ce3597851110001cf6248b7e62b94fe2fd763abf8f5fa13e903fe5ffc26b0bdbd22e7a04332ef";
  static const String apiUrl = "https://api.openrouteservice.org/v2/directions/driving-car/geojson";

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(apiUrl);
    print("Start: ${start.latitude}, ${start.longitude}");
    print("End: ${end.latitude}, ${end.longitude}");

    final body = jsonEncode({
      "coordinates": [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude]
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: body,
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Parsed Data: $data");

        if (data.containsKey("features") && data["features"].isNotEmpty) {
          final List<dynamic> coordinates = data["features"][0]["geometry"]["coordinates"];
          print("Coordinates: $coordinates");

          return coordinates.map((point) => LatLng(point[1], point[0])).toList();
        } else {
          print("No features found in response.");
        }
      } else {
        print("Lỗi tải tuyến đường: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
    return [];
  }
}

// RouteInputWidget class for user input of start and end addresses
class RouteInputWidget extends StatefulWidget {
  final Function(List<double>) onStartStationLocationFound;
  final Function(List<double>) onEndStationLocationFound;
  final VoidCallback onFindRoute;

  const RouteInputWidget({
    Key? key,
    required this.onStartStationLocationFound,
    required this.onEndStationLocationFound,
    required this.onFindRoute,
  }) : super(key: key);

  @override
  _RouteInputWidgetState createState() => _RouteInputWidgetState();
}

class _RouteInputWidgetState extends State<RouteInputWidget> {
  final startController = TextEditingController();
  final endController = TextEditingController();
  bool isLoading = false;
  List<String> startSuggestions = [];
  List<String> endSuggestions = [];
  OverlayEntry? startOverlayEntry;
  OverlayEntry? endOverlayEntry;
  final LayerLink findRouteButtonLayerLink = LayerLink();

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
    startOverlayEntry?.remove();
    endOverlayEntry?.remove();
    super.dispose();
  }

  // Hàm gọi Nominatim API để lấy gợi ý địa chỉ
  Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(query)}&format=json&limit=5&addressdetails=1&countrycodes=VN');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'YourAppName/1.0 (your.email@example.com)', // Cập nhật thông tin app của bạn
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item['display_name'] as String).toList();
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
    return [];
  }


  // Hàm hiển thị danh sách gợi ý trong Overlay dưới nút "Tìm Đường"
  void showSuggestionsOverlay({
    required List<String> suggestions,
    required Function(String) onSuggestionSelected,
    required bool isStartField,
  }) {
    // Ẩn gợi ý của ô kia (nếu có)
    if (isStartField) {
      endOverlayEntry?.remove();
      endOverlayEntry = null;
    } else {
      startOverlayEntry?.remove();
      startOverlayEntry = null;
    }

    // Xóa gợi ý hiện tại (nếu có)
    if (isStartField) {
      startOverlayEntry?.remove();
      startOverlayEntry = null;
    } else {
      endOverlayEntry?.remove();
      endOverlayEntry = null;
    }

    if (suggestions.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final newOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32, // Trừ padding ngang
        child: CompositedTransformFollower(
          link: findRouteButtonLayerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 50), // Đặt vị trí ngay dưới nút "Tìm Đường"
          child: Material(
            elevation: 4.0,
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints(
                maxHeight: 200, // Giới hạn chiều cao tối đa của danh sách gợi ý
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      onSuggestionSelected(suggestions[index]);
                      if (isStartField) {
                        startOverlayEntry?.remove();
                        startOverlayEntry = null;
                        setState(() {
                          startSuggestions = [];
                        });
                      } else {
                        endOverlayEntry?.remove();
                        endOverlayEntry = null;
                        setState(() {
                          endSuggestions = [];
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(newOverlayEntry);
    if (isStartField) {
      startOverlayEntry = newOverlayEntry;
    } else {
      endOverlayEntry = newOverlayEntry;
    }
  }

  Future<void> _handleFindRoute() async {
    final startAddress = startController.text.trim();
    final endAddress = endController.text.trim();

    if (startAddress.isEmpty || endAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ địa chỉ đi và đến")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final startCoords = await geocodeAddress(startAddress);
      final endCoords = await geocodeAddress(endAddress);

      widget.onStartStationLocationFound(startCoords);
      widget.onEndStationLocationFound(endCoords);

      widget.onFindRoute();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi khi lấy tọa độ: $e\nGợi ý: Hãy thử chọn một địa chỉ từ danh sách gợi ý, hoặc nhập tên đường chính và quận/thành phố (ví dụ: Nguyễn Huệ, Quận 1, Hồ Chí Minh).",
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 30),
          _buildLocationField(
            "Nhập địa điểm đi",
            Icons.location_on,
            startController,
            Colors.red,
            startSuggestions,
                (suggestion) {
              setState(() {
                startController.text = suggestion;
                startSuggestions = [];
              });
            },
                (value) async {
              final suggestions = await fetchSuggestions(value);
              setState(() {
                startSuggestions = suggestions;
                showSuggestionsOverlay(
                  suggestions: startSuggestions,
                  onSuggestionSelected: (suggestion) {
                    startController.text = suggestion;
                    setState(() {
                      startSuggestions = [];
                    });
                  },
                  isStartField: true,
                );
              });
            },
          ),
          SizedBox(height: 8),
          _buildLocationField(
            "Nhập địa điểm đến",
            Icons.place,
            endController,
            Colors.black,
            endSuggestions,
                (suggestion) {
              setState(() {
                endController.text = suggestion;
                endSuggestions = [];
              });
            },
                (value) async {
              final suggestions = await fetchSuggestions(value);
              setState(() {
                endSuggestions = suggestions;
                showSuggestionsOverlay(
                  suggestions: endSuggestions,
                  onSuggestionSelected: (suggestion) {
                    endController.text = suggestion;
                    setState(() {
                      endSuggestions = [];
                    });
                  },
                  isStartField: false,
                );
              });
            },
          ),
          SizedBox(height: 16),
          CompositedTransformTarget(
            link: findRouteButtonLayerLink,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleFindRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : const Text("Tìm Đường", style: TextStyle(color: Colors.green)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(
      String hint,
      IconData icon,
      TextEditingController controller,
      Color iconColor,
      List<String> suggestions,
      Function(String) onSuggestionSelected,
      Function(String) onTextChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    onTextChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// MapScreen class to display the map and route
class MapScreenn extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenn> {
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  LatLng? startPoint;
  LatLng? endPoint;
  double _currentZoom = 14.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void zoomToFitMarkers(LatLng start, LatLng end) {
    final bounds = LatLngBounds.fromPoints([start, end]);
    _mapController.fitBounds(bounds, options: FitBoundsOptions(padding: EdgeInsets.all(50)));
  }

  Future<void> _getRoute() async {
    if (startPoint == null || endPoint == null) return;

    if (startPoint!.latitude == endPoint!.latitude && startPoint!.longitude == endPoint!.longitude) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Điểm đi và điểm đến không được trùng nhau.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      routePoints = [];
    });

    try {
      final points = await RouteService.getRoute(startPoint!, endPoint!);
      setState(() {
        routePoints = points;
        isLoading = false;
      });

      if (points.isNotEmpty) {
        zoomToFitMarkers(startPoint!, endPoint!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy tuyến đường từ API.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy dữ liệu từ API: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RouteInputWidget(
            onStartStationLocationFound: (coords) {
              setState(() {
                startPoint = LatLng(coords[1], coords[0]);
              });
            },
            onEndStationLocationFound: (coords) {
              setState(() {
                endPoint = LatLng(coords[1], coords[0]);
              });
            },
            onFindRoute: () async {
              if (startPoint != null && endPoint != null) {
                await _getRoute();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập đầy đủ và chính xác địa chỉ.')),
                );
              }
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.green),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: startPoint ?? LatLng(10.7769, 106.7009),
                initialZoom: _currentZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    if (startPoint != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: startPoint!,
                        child: Icon(Icons.location_on, color: Colors.black, size: 40),
                      ),
                    if (endPoint != null)
                      Marker(
                        width: 40,
                        height: 40,
                        point: endPoint!,
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
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}