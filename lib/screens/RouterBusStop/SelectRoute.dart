import 'package:flutter/material.dart';
import 'package:busmap/screens/RouterBusStop/SelectRoute.dart';
import 'package:busmap/Router.dart';
import 'package:busmap/service/BusRouterService.dart';
import 'package:busmap/models/BusRouterModel/BusRouteDetail.dart';
import 'package:busmap/screens/RouterBusStop/DetailBus.dart';
import 'package:fluro/fluro.dart';


void main() {
  runApp(SelectRount());
}

class SelectRount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BusSelectRount(),
    );
  }
}

class BusSelectRount extends StatefulWidget {
  @override
  _BusScreenState createState() => _BusScreenState();
}

class _BusScreenState extends State<BusSelectRount> {
  List<BusRouteDetail> allRoutes = [];
  List<BusRouteDetail> filteredRoutes = [];
  bool showFavorites = false;

  @override
  void initState() {
    super.initState();
    fetchAllBusRoutes();
  }

  Future<void> fetchAllBusRoutes() async {
    List<BusRouteDetail> routes = [];
    for (int i = 1; i <= 9; i++) {
      try {
        var routeDetail = await ApiService().fetchBusRouteDetail(i.toString());
        routes.add(routeDetail);
      } catch (e) {
        print('Lỗi khi lấy dữ liệu tuyến $i: $e');
      }
    }
    if (mounted) {
      setState(() {
        allRoutes = routes;
        filteredRoutes = allRoutes;
      });
    }
  }
  String extractPrice(String tickets) {
    RegExp regex = RegExp(r'(\d{1,3}(?:,\d{3})*) VNĐ'); // Lấy giá vé có định dạng số + "VNĐ"
    Match? match = regex.firstMatch(tickets);
    return match != null ? match.group(1)! + " VNĐ" : "Không có giá";
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chọn tuyến xe", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              FluroRouterConfig.router.navigateTo(context, "/mapSearch");
            }
          },


        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Nút Tất cả - Yêu thích
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                // onTap: () => setState(() => toggleFavorites()),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: !showFavorites ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text("TẤT CẢ", style: TextStyle(color: !showFavorites ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                // onTap: () => setState(() => toggleFavorites()),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: showFavorites ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text("YÊU THÍCH", style: TextStyle(color: showFavorites ? Colors.white : Colors.green)),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Danh sách tuyến xe
          Expanded(
            child: ListView.builder(
              itemCount: filteredRoutes.length,
              itemBuilder: (context, index) {
                var route = filteredRoutes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      route.routeId == "metro" ? Icons.directions_subway : Icons.directions_bus,
                      color: route.routeId == "metro" ? Colors.red : Colors.blue,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tuyến xe: ${route.routeId}',  // Hiển thị RouteId trước
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          route.routeName,  // Hiển thị RouteName phía dưới
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(route.operationTime, style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 10),
                            Icon(Icons.attach_money, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(extractPrice(route.tickets), style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      FluroRouterConfig.router.navigateTo(
                        context,
                        "/busDetail/${route.routeId}",
                        transition: TransitionType.fadeIn, // Hiệu ứng chuyển trang
                      );
                    },

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
