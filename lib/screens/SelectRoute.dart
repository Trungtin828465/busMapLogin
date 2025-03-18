import 'package:flutter/material.dart';
import 'package:busmap/screens/SelectRoute.dart';
import 'package:busmap/Router.dart';
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
  List<Map<String, dynamic>> allRoutes = [
    {"id": 1, "name": "Metro 1", "route": "Bến Thành - Suối Tiên", "price": "20k VNĐ", "time": "05:00 - 22:00", "favorite": true, "type": "metro"},
    {"id": 2, "name": "D4", "route": "Vinhomes Grand Park - Bến xe Sài Gòn", "price": "7k VNĐ", "time": "05:00 - 22:00", "favorite": true, "type": "bus"},
    {"id": 3, "name": "Tuyến xe 01", "route": "Bến Thành - Bến xe Chợ Lớn", "price": "5k VNĐ", "time": "05:00 - 20:15", "favorite": false, "type": "bus"},
    {"id": 4, "name": "Tuyến xe 03", "route": "Bến Thành - Thạnh Xuân", "price": "6k VNĐ", "time": "04:00 - 20:45", "favorite": true, "type": "bus"},
    {"id": 5, "name": "Tuyến xe 04", "route": "Bến Thành - Cộng Hòa - An Sương", "price": "6k VNĐ", "time": "05:00 - 20:15", "favorite": false, "type": "bus"},
    {"id": 6, "name": "Tuyến xe 05", "route": "Chợ Lớn - Biên Hòa", "price": "10k VNĐ", "time": "04:50 - 17:50", "favorite": true, "type": "bus"},
    {"id": 7, "name": "Tuyến xe 06", "route": "Chợ Lớn - Đại học Nông Lâm", "price": "7k VNĐ", "time": "04:55 - 21:00", "favorite": true, "type": "bus"},
  ];

  List<Map<String, dynamic>> filteredRoutes = [];
  bool showFavorites = false;

  @override
  void initState() {
    super.initState();
    filteredRoutes = allRoutes;
  }

  void toggleFavorites() {
    setState(() {
      showFavorites = !showFavorites;
      filteredRoutes = showFavorites
          ? allRoutes.where((route) => route["favorite"]).toList()
          : allRoutes;
    });
  }

  void toggleFavorite(int id) {
    setState(() {
      int index = allRoutes.indexWhere((route) => route["id"] == id);
      allRoutes[index]["favorite"] = !allRoutes[index]["favorite"];
      filteredRoutes = showFavorites
          ? allRoutes.where((route) => route["favorite"]).toList()
          : allRoutes;
    });
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
            Navigator.pop(context); // Quay lại trang trước nếu có
          } else {
            // Nếu không có trang trước, điều hướng về "/home"
            FluroRouterConfig.router.navigateTo(
              context, "/home",
              replace: true, // Xóa trang hiện tại khỏi stack
            );
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
                onTap: () => setState(() => toggleFavorites()),
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
                onTap: () => setState(() => toggleFavorites()),
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
                      route["type"] == "metro" ? Icons.directions_subway : Icons.directions_bus,
                      color: route["type"] == "metro" ? Colors.red : Colors.blue,
                    ),
                    title: Text(route["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route["route"]),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(route["time"], style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 10),
                            Icon(Icons.attach_money, size: 16, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(route["price"], style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        route["favorite"] ? Icons.favorite : Icons.favorite_border,
                        color: route["favorite"] ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => toggleFavorite(route["id"]),
                    ),
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
