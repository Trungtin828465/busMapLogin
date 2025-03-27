import 'package:busmap/models/BusRouterModel/BusRouteDetail.dart';
import 'package:flutter/material.dart';
import 'package:busmap/screens/Map/MapGps.dart';
import 'package:busmap/service/BusRouterService.dart';

class BusDetailScreen extends StatefulWidget {
  final String routeId;
  BusDetailScreen({required this.routeId});

  @override
  _BusDetailScreenState createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  late Future<BusRouteDetail> busRouteDetail;

  @override
  void initState() {
    super.initState();
    busRouteDetail = ApiService().fetchBusRouteDetail(widget.routeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuyến xe ${widget.routeId}'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Biểu tượng mũi tên quay lại
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);  // Quay lại trang trước đó
            } else {
              Navigator.pushNamed(context, "/home");  // Nếu không có trang trước, về home
            }
          },

        ),
      ),

      body: FutureBuilder<BusRouteDetail>(
        future: busRouteDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text("Không có dữ liệu"));
          }

          final route = snapshot.data!;
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: MapGps(),
              ),
              Expanded(
                flex: 2,
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        tabs: [
                          Tab(text: 'Biểu đồ giờ'),
                          Tab(text: 'Trạm dừng'),
                          Tab(text: 'Thông tin'),
                          Tab(text: 'Đánh giá'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ScheduleTab(),  // Biểu đồ giờ (cố định 15 phút
                            StopsTab(route: route), // Lượt đi
                            InfoTab(route: route),
                            ReviewTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ======================== 🕒 Biểu đồ giờ (cố định 15 phút) ========================
class ScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> scheduleTimes = [];
    for (int hour = 5; hour <= 22; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        String time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        scheduleTimes.add(time);
      }
    }

    return ListView.builder(
      itemCount: scheduleTimes.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.access_time, color: Colors.green),
          title: Text(scheduleTimes[index], style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.directions_bus, color: Colors.blue),
        );
      },
    );
  }
}
// ======================== 🚏 Danh sách trạm dừng ========================
class StopsTab extends StatefulWidget {
  final BusRouteDetail route;

  StopsTab({required this.route});

  @override
  _StopsTabState createState() => _StopsTabState();
}
class _StopsTabState extends State<StopsTab> {
  bool isOutbound = false; // Mặc định hiển thị lượt đi

  @override
  Widget build(BuildContext context) {
    List<String> parseStops(String rawData) {
      return rawData.split(" - ").map((stop) => stop.trim()).toList();
    }

    List<String> stops = isOutbound
        ? parseStops(widget.route.outboundDescription) // Lượt về
        : parseStops(widget.route.inboundDescription); // Lượt đi

    return Column(
      children: [
        // Header chuyển đổi lượt đi / lượt về
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOutbound ? "📍 Lượt về" : "📍 Lượt đi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<bool>(
                value: isOutbound,
                icon: Icon(Icons.swap_vert),
                items: [
                  DropdownMenuItem(value: false, child: Text("Lượt đi")),
                  DropdownMenuItem(value: true, child: Text("Lượt về")),
                ],
                onChanged: (value) {
                  setState(() {
                    isOutbound = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Danh sách trạm dừng
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index].trim();
              bool isFirst = index == 0;
              bool isLast = index == stops.length - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon trạm và đường kẻ timeline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          // Icon trạm xe buýt
                          Icon(
                            Icons.directions_bus,
                            color: isFirst ? Colors.green : (isLast ? Colors.red : Colors.grey),
                            size: 24, // Điều chỉnh kích thước icon
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.green,
                            ),
                        ],
                      ),
                      SizedBox(width: 12),

                      // Tên trạm dừng
                      Expanded(
                        child: Text(
                          stop,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Thêm khoảng cách giữa các trạm
                  SizedBox(height: 10),
                  if (!isLast) Divider(thickness: 1, color: Colors.grey[300]),
                  SizedBox(height: 10),
                ],
              );

            },
          ),
        ),
      ],
    );
  }
}
// ======================== ℹ️ Thông tin tuyến xe ========================
class InfoTab extends StatelessWidget {
  final BusRouteDetail route;
  InfoTab({required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề tuyến xe
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                SizedBox(width: 10),
                Text(
                  "Tuyến số: ${route.routeNo}",
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Tên tuyến
            Row(
              children: [
                Icon(Icons.route, color: Colors.orange, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    route.routeName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Divider(),

            // Thời gian hoạt động
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.green, size: 24),
                SizedBox(width: 10),
                Text(
                  "Thời gian: ${extractFormattedTickets(route.operationTime)}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Số chỗ ngồi
            Row(
              children: [
                Icon(Icons.event_seat, color: Colors.purple, size: 24),
                SizedBox(width: 10),
                Text(
                  "Số chỗ ngồi: ${extractFormattedTickets(route.numOfSeats)}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Tổng số chuyến đi
            Row(
              children: [
                Icon(Icons.directions, color: Colors.teal, size: 24),
                SizedBox(width: 10),
                Text(
                  "Tổng số chuyến: ${route.totalTrip}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Quãng đường (Distance)
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.deepOrange, size: 24),
                SizedBox(width: 10),
                Text(
                  "Quãng đường: ${route.distance} km",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(),

            // Giá vé - Căn chỉnh đẹp hơn
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.money, color: Colors.red, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        "Giá vé: ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        extractFormattedTickets(route.tickets),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý và làm sạch giá vé từ API
  String extractFormattedTickets(String tickets) {
    // Loại bỏ <br/> và &nbsp;
    String cleanedTickets = tickets
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')  // Thay <br/> thành xuống dòng
        .replaceAll(RegExp(r'&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp'), ' ')      // Thay &nbsp; thành khoảng trắng
        .replaceAll(RegExp(r'<[^>]*>'), '')      // Xóa tất cả thẻ HTML còn lại
        .trim(); // Xóa khoảng trắng thừa ở đầu/cuối

    return cleanedTickets;
  }

}
// ======================== ⭐ Đánh giá tuyến xe ========================
class ReviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        ListTile(
          leading: Icon(Icons.person, color: Colors.green),
          title: Text("Nguyễn Văn A"),
          subtitle: Text("Xe chạy đúng giờ, tài xế thân thiện."),
          trailing: Icon(Icons.star, color: Colors.yellow),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Colors.green),
          title: Text("Trần Thị B"),
          subtitle: Text("Trạm dừng sạch sẽ, dễ tìm."),
          trailing: Icon(Icons.star, color: Colors.yellow),
        ),
      ],
    );
  }
}
