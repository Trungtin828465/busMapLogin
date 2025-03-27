import 'package:flutter/material.dart';
import 'Map/MapGps.dart';
import 'package:busmap/Router.dart';
import 'package:fluro/fluro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? "Không có email";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Map"),
        backgroundColor: Colors.green,
        leading: Icon(Icons.directions_bus, color: Colors.yellow),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Email: ${userEmail ?? "Đang tải..."}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          // Ô tìm kiếm địa điểm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Bản đồ GPS
          SizedBox(
            width: 400,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MapGps(),
                ),
              ),
            ),
          ),

          // Danh sách chức năng
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              children: [
                _buildFeatureItem(Icons.directions_bus, 'Tra cứu', '/search_bus'),
                _buildFeatureItem(Icons.route, 'Tìm đường', '/find_route'),
                _buildFeatureItem(Icons.location_on, 'Trạm gần đây', '/mapSearch'),
                _buildFeatureItem(Icons.feedback, 'Góp ý', '/feedback'),
                _buildFeatureItem(Icons.school, 'Student Hub', '/student_hub'),
                _buildFeatureItem(Icons.business, 'Buýt Doanh nghiệp', '/business_bus'),
                _buildFeatureItem(Icons.directions_car, 'Tìm kiếm xe', '/find_car'),
                _buildFeatureItem(Icons.chat, 'Chat Nhóm', '/chat_group'),
              ],
            ),
          ),
        ],
      ),

      // Thanh điều hướng dưới cùng
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              FluroRouterConfig.router.navigateTo(context, "/home", transition: TransitionType.fadeIn);
              break;
            case 1:
              FluroRouterConfig.router.navigateTo(context, "/notifications", transition: TransitionType.fadeIn);
              break;
            case 2:
              FluroRouterConfig.router.navigateTo(context, "/scan_qr", transition: TransitionType.fadeIn);
              break;
            case 3:
              FluroRouterConfig.router.navigateTo(context, "/favorites", transition: TransitionType.fadeIn);
              break;
            case 4:
              FluroRouterConfig.router.navigateTo(context, "/profile", transition: TransitionType.fadeIn);
              break;
          }
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Quét mã'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }

  // Hàm tạo một item chức năng
  Widget _buildFeatureItem(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        FluroRouterConfig.router.navigateTo(
          context, route,
          transition: TransitionType.fadeIn,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: Colors.green),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
