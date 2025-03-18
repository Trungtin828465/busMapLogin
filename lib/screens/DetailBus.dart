import 'package:flutter/material.dart';
import 'package:busmap/screens/MapGps.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BusDetailScreen(),
  ));
}

class BusDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuyến xe 01'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Phần trên: Bản đồ
          Expanded(
            flex: 1, // Chiếm 1/2 màn hình
            child: MapGps(),
          ),

          // Phần dưới: Tabs (Biểu đồ giờ, Trạm dừng, Thông tin, Đánh giá)
          Expanded(
            flex: 1, // Chiếm 1/2 màn hình
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  // Tabs điều hướng
                  TabBar(
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Biểu đồ giờ'),
                      Tab(text: 'Trạm dừng'),
                      Tab(text: 'Thông tin'),
                      Tab(text: 'Đánh giá'),
                    ],
                  ),

                  // Nội dung tab
                  Expanded(
                    child: TabBarView(
                      children: [
                        ScheduleTab(),
                        StopsTab(),
                        InfoTab(),
                        ReviewTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Tab: Biểu đồ giờ (Demo dữ liệu)
// class ScheduleTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.all(10),
//       children: [
//         ListTile(
//           leading: Icon(Icons.schedule, color: Colors.green),
//           title: Text("06:00 - 23:00"),
//           subtitle: Text("Thời gian hoạt động"),
//         ),
//         ListTile(
//           leading: Icon(Icons.directions_bus, color: Colors.blue),
//           title: Text("15 phút"),
//           subtitle: Text("Tần suất chuyến"),
//         ),
//       ],
//     );
//   }
// }


class ScheduleTab extends StatelessWidget {
  final List<String> scheduleTimes = [
    "05:00", "05:15", "05:30", "05:45", "06:00", "06:15",
    "06:30", "06:45", "07:00", "07:15", "07:30", "07:45",
    "08:00", "08:15", "08:30", "08:45", "09:00", "09:15",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh tiêu đề "HÔM NAY"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back, color: Colors.green), // Mũi tên trái
            Text(
              "HÔM NAY",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.green), // Mũi tên phải
          ],
        ),
        SizedBox(height: 10),

        // Danh sách cuộn lịch trình xe buýt
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: scheduleTimes.map((time) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green, // Màu xanh lá
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(width: 10),

                    // Hiển thị giờ xe chạy
                    Text(
                      time,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}


// // Tab: Trạm dừng (Demo danh sách trạm)
// class StopsTab extends StatelessWidget {
//   final List<String> stops = [
//     "Công Trường Mê Linh",
//     "Bến Bạch Đằng",
//     "Cục Hải Quan TP",
//     "Chợ Cũ",
//     "Trường Cao Thắng",
//     "Trạm trung chuyển Hàm Nghi",
//     "Trường Ernst Thalmann",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: EdgeInsets.all(10),
//       itemCount: stops.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: Icon(Icons.location_on, color: Colors.red),
//           title: Text(stops[index]),
//         );
//       },
//     );
//   }
// }
// Tab: Trạm dừng (Demo danh sách trạm)
class StopsTab extends StatelessWidget {
  final List<String> stops = [
    "Công Trường Mê Linh",
    "Bến Bạch Đằng",
    "Cục Hải Quan TP",
    "Chợ Cũ",
    "Trường Cao Thắng",
    "Trạm trung chuyển Hàm Nghi",
    "Trường Ernst Thalmann",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.location_on, color: Colors.red),
          title: Text(stops[index]),
        );
      },
    );
  }
}

// Tab: Thông tin tuyến xe (Demo)
class InfoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thông tin tuyến xe:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("• Lộ trình: Bến Thành → Bến xe Chợ Lớn"),
          Text("• Cự ly: 10km"),
          Text("• Giá vé: 7.000đ"),
        ],
      ),
    );
  }
}

// Tab: Đánh giá (Demo)
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
